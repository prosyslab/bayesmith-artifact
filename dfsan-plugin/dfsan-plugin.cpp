#include<bits/stdc++.h>
#include<tianyichen/std.h>
//#include<ranges>
#include<FriendlyRewriter.h>
#include"lclang.h"
#include"clang/Frontend/FrontendPluginRegistry.h"

using namespace tianyichen::std;
using namespace clang;

struct FileLine{
	string filename;int ln;
	FileLine(string_view s){
		auto pos=s.find(':');
		filename=s.substr(0,pos);
		ln=atoi(s.data()+pos+1);
	}
	bool operator<(const FileLine& b)const{	return filename==b.filename?ln<b.ln:filename<b.filename;}
	operator string()const{	return filename+":"+to_string(ln);}
};
auto& operator<<(ostream& o,const FileLine& f){
	return o<<make_pair(f.filename,f.ln);
}

CompilerInstance* CIp;
string workspace="/tmp/";
Logger loc_vars,plog,visited_f,visited_edges;
string filename,full_filename,original_code;
using ofileloc=string;
unordered_map<ofileloc,set<ofileloc>> df_edge;
unordered_map<ofileloc,set<string>> sink_labels;
map<FileLine,int>interested;
set<const FileLine*>visited;
set<string>sink_file_source_vars,blacklist;
//>>0&1, source
//>>1&1, sink

map<string,vector<string>>dfsan_labels;
int dfsan_id_used;
bool dfsan_bad_used;
void load_labels(){
	ifstream i(workspace+"loc_vars.txt");
	string a,b;
	while(i>>a>>b)dfsan_labels[a].push_back(b),++dfsan_id_used;
}
void write_labels(){
	loc_vars.open(workspace+"loc_vars.txt");
	for(auto&x:dfsan_labels){
		for(auto&y:x.second)
			loc_vars+x.first-y;
	}
}

enum Mode{
	disabled=0,
	genSource,
	genSink,
	writeIns
}mode;
const char* Mode_str[]={"disabled","genSource","genSink","writeIns"};
string get_new_label(const string& loc,const string& var,bool source){
	static Logger labellog(workspace+"label.log",ios::app);
	string rt="_SaN_";
	auto hh=hash<string>{}(loc+var)>>1<<1|source;
	for(int i=0;i<8;++i)rt.push_back("0123456789abcdef"[hh&15]),hh>>=4;
	dfsan_labels[loc].push_back(rt);
	labellog+loc+var+source-rt;
	return rt;
}
struct DfsanFactory{
	DeclStmt* varInitTemplate;
	CallExpr* labelAssignTemplate;
	void init1(DeclStmt* d){
		varInitTemplate=d;
		d->dumpColor();
	}
	void init2(CallExpr* c){
		labelAssignTemplate=c;
		c->dumpColor();
	}
};

FriendlyRewriter r;
using namespace llvm;
class DfsanClassVisitor : public RecursiveASTVisitor<DfsanClassVisitor>
{
private:
	ASTContext *context;
public:
	void setContext(ASTContext &context)
	{
		this->context = &context;
	}
	IntegerLiteral* first=0;

	bool VisitIntegerLiteral(IntegerLiteral*s)
	{
		return 1;
		if(!first){
			cerr<<"initing"<<first<<"\n";
			first=s;
		}else{
			first->dump();
			s->dumpColor();
				cerr<<"assign\n";
			memcpy(s,first,sizeof(IntegerLiteral));
		}
		return true;
	}

	bool VisitVarDecl(VarDecl*d){
		return 1;
		if(auto f=dyn_cast<ParmVarDecl>(d);f)return 1;
		if(r.IsInMainFile(d)){
			auto V=APInt(32,42,true);
			auto liter=IntegerLiteral::Create(*r.Context,V,context->IntTy,SourceLocation());
			cerr<<"set init\n";
			//d->dumpColor();
			//first->dump();
			d->setInit(liter);
			//d->dumpColor();
		}
		return 1;
	}
	map<string,FunctionDecl*>funname_decl;
	bool VisitFunctionDecl(FunctionDecl* d){
		return 1;
	}
	bool VisitStmt(Stmt*s){
		if(!r.IsInMainFile(s))return 1;
		//s->dumpColor();
		return 1;
	}

};
namespace ASTMatchModify{
using namespace clang::ast_matchers;
StatementMatcher DeclMatcher=
anyOf(
	implicitCastExpr(hasCastKind(CK_LValueToRValue)).bind("ie")
	,binaryOperator(
		allOf(
			anyOf(hasOperatorName("="),hasOperatorName("|="),hasOperatorName("&="),
				hasOperatorName("+="),hasOperatorName("*="),hasOperatorName("-=")),
			unless(hasAncestor(binaryOperator()))
		)
	).bind("binop")
	
	//,returnStmt().bind("return")
	//,expr().bind("expr")
	//,ifStmt().bind("ifstmt")
	,callExpr(
		unless(hasAncestor(binaryOperator()))
	).bind("callexp")
)
;

struct MyASTMatcherCallBack:MatchFinder::MatchCallback{
	ASTContext *Context;
	FriendlyRewriter&r;
	string query_src_loc(SourceLocation loc,bool lineonly=true){
		auto fs=loc.printToString(*r.SMp);
		int cnt=0;
		auto a=fs.rfind('/');
		auto b=fs.rfind(':');
		//fs=fs.substr(a+1,b-a-1);
		return fs;
	}
	int phase=0;
	MyASTMatcherCallBack(FriendlyRewriter&rewriter):r{rewriter}{}
	enum _mtype{
		invalid,
		ie,
		binop,
		ifstmt,
		callexp,
		vardecl,
	}mtype;
	const ImplicitCastExpr* s_ie;
	const BinaryOperator* s_binop;
	const IfStmt* s_ifstmt;
	const CallExpr* s_callexp;
	const VarDecl* s_vardecl;
	static auto filter(set<Expr*>&& a,function<bool(Expr*)>f){
		set<Expr*> rt;
		for(auto&& x:a)if(f(x))rt.insert(x);
		return rt;
	}
	auto source_vars(){
		if(mtype==binop){
			auto rt=s_binop->getLHS();
			return rt->isLValue()&&!rt->refersToBitField()?set<Expr*>{{rt}}:set<Expr*>{};
		}
		auto rt=filter(r.find_vars_expr(_source_vars()),
			[](auto e){return e->isLValue()&&!e->refersToBitField();});
		return rt;
	}
	const clang::Expr* _source_vars(){
		switch(mtype){
			case binop:
				return s_binop->getLHS();
			case ifstmt:
				return s_ifstmt->getCond();
			case callexp:
				return s_callexp;//TBD
			default:assert(0);
		}
	}
	auto sink_vars(){
		auto rt=r.find_vars_expr(_sink_vars());
		//erase_if(rt,var_filter);
		return rt;
	}
	const clang::Expr* _sink_vars(){
		switch(mtype){
			case binop:
				return s_binop->getRHS();
			case ifstmt:
				return s_ifstmt->getCond();
			case callexp:
				return s_callexp;//TBD
			default:assert(0);
		}
	}
	static string first_line(string src_loc){
		while(src_loc.back()!=':')src_loc.pop_back();
		src_loc.push_back('1');
		return src_loc;
	}
	bool IsInterestingPair(string_view loca,string_view locb){
		string_view filename=loca.substr(0,loca.find(':'));
		int a=atoi(loca.substr(1+loca.find(':')));
		int b=atoi(locb.substr(1+locb.find(':')));
		for(auto&x:interested){
			if(x.first.filename==filename&&between(x.first.ln,a,b)){
				if(blacklist.contains(x.first.filename))return 0;
				if(mtype==binop||mtype==ie)visited.insert(&x.first);
				plog+"interesting "+x.first+loca-locb;
				return 1;
			}
		}
		return 0;
	}
	void log_var_types(const set<Expr*>&res){
		PrintingPolicy dp(CIp->getLangOpts());
		plog-"vartypes:";
		for(auto x:res){
			x->dumpColor();
			plog-make_pair(r.get_source(x),x->getType().getAsString(dp));
		}
	}
	void run(const MatchFinder::MatchResult &Result){
		Context= Result.Context;
		r.Context=Context;
		auto&SM=Context->getSourceManager();
		const Stmt* FS=0;
		mtype=invalid;
		s_binop = Result.Nodes.getNodeAs<BinaryOperator>("binop");
		if(s_binop)FS=s_binop,mtype=binop;
		if(!FS)
			if(s_ifstmt=Result.Nodes.getNodeAs<IfStmt>("ifstmt"))FS=s_ifstmt,mtype=ifstmt;
		if(!FS)
			if(s_callexp=Result.Nodes.getNodeAs<CallExpr>("callexp"))FS=s_callexp,mtype=callexp;
		if(!FS)
			if(s_ie=Result.Nodes.getNodeAs<ImplicitCastExpr>("ie"))FS=s_ie,mtype=ie;
		if(!FS){
			if(s_vardecl=Result.Nodes.getNodeAs<VarDecl>("vardecl"))
			{
				//s_vardecl->getinit
			}
		}
		if(mtype==invalid)return;
		if(!FS||!r.IsInMainFile(FS))return;
		auto source=r.get_source(FS);
		auto src_loc=split(query_src_loc(FS->getBeginLoc()),'/').back();
		auto endLoc=split(query_src_loc(FS->getEndLoc()),'/').back();
		if(mtype==ie&&r.get_source(FS).find("_SaN_")!=string::npos)return;
		plog.ccl.clear();
		plog+"match discovered "+src_loc-endLoc;
		if(!IsInterestingPair(src_loc,endLoc))return;
		plog+"is interesting "+src_loc-endLoc;
		//plog.ccl.push_back(&cerr);
		plog+"src:"-r.get_source(FS);
		auto range=make_pair(interested.lower_bound({src_loc}),
			interested.upper_bound({endLoc}));
		for(auto it=range.first;it!=range.second;++it){
			//FS->dumpColor();
			if(mode==genSource){
				if(it->second>>2&1){//uni source, same as above except uniq_name is const
					if(mtype==ie)return;
					//assert(lhs); //not ture can be MemberExpr->-ImplicitCastExpr->DeclRefExpr, e.g. png_ptr->zbuf_size
					for(auto& varname:source_vars()){
						plog+"source"<DUM(varname);
						dfsan_bad_used=1;
						string uniq_name="_SaN_bad00000";
						if(mtype!=binop){
							plog+"usource:"+int(mtype)+src_loc-endLoc;
						} else if(mtype==binop){
							plog<"source binop\n";
							//auto dfsan_begin=",dfsan_set_label("+uniq_name+",&"+varname+",sizeof("+varname+"))";
							if(s_binop->getLHS()->HasSideEffects(*Context)){
								plog+"HasSideEffects"-r.get_source(s_binop->getLHS());
								continue;
							}
							varname->dumpColor();
							auto vn=r.get_source(varname);
							if(vn.empty()){
								plog-"ASSERT1";
								varname->dump();
								continue;
							}

							if(!r.isRewritable(FS->getBeginLoc())||!r.isRewritable(FS->getEndLoc())){
								plog-"source not accessible";
								//https://stackoverflow.com/a/32118182
								//r.InsertTextBefore(r.SMp->getFileLoc(FS->getBeginLoc()),"(");
								//r.InsertTextAfterToken(r.SMp->getFileLoc(FS->getEndLoc()),
								//	",dfsansrc(\""+uniq_name+"\"),dfsan_set_label("+uniq_name+",&"+vn+",sizeof("+vn+")),"+vn+")");
								continue;
							}
							r.InsertBefore(FS,"(");
							r.InsertTextAfterToken(FS->getEndLoc(),
								",dfsansrc(\""+uniq_name+"\"),dfsan_set_label("+uniq_name+",&"+vn+",sizeof("+vn+")),"+vn+")");
						}
					}
				}
				else if(it->second&1){
					//data src
					if(mtype==ie)return;
					//assert(lhs); //not ture can be MemberExpr->-ImplicitCastExpr->DeclRefExpr, e.g. png_ptr->zbuf_size
					for(auto& varname:source_vars()){
						plog+"source"<DUM(varname);
						auto uniq_name=get_new_label(it->first,r.get_source(varname),1);
						if(mtype!=binop){
							plog+"usource:"+int(mtype)+src_loc-endLoc;
						} else if(mtype==binop){
							plog<"source binop\n";
							//auto dfsan_begin=",dfsan_set_label("+uniq_name+",&"+varname+",sizeof("+varname+"))";
							if(s_binop->getLHS()->HasSideEffects(*Context)){
								plog+"HasSideEffects"-r.get_source(s_binop->getLHS());
								continue;
							}
							varname->dumpColor();
							auto vn=r.get_source(varname);
							if(vn.empty()){
								plog-"ASSERT1";
								varname->dump();
								continue;
							}

							if(!r.isRewritable(FS->getBeginLoc())||!r.isRewritable(FS->getEndLoc())){
								plog-"source not accessible";
								//https://stackoverflow.com/a/32118182
								//r.InsertTextBefore(r.SMp->getFileLoc(FS->getBeginLoc()),"(");
								//r.InsertTextAfterToken(r.SMp->getFileLoc(FS->getEndLoc()),
								//	",dfsansrc(\""+uniq_name+"\"),dfsan_set_label("+uniq_name+",&"+vn+",sizeof("+vn+")),"+vn+")");
								continue;
							}
							r.InsertBefore(FS,"(");
							r.InsertTextAfterToken(FS->getEndLoc(),
								",dfsansrc(\""+uniq_name+"\"),dfsan_set_label("+uniq_name+",&"+vn+",sizeof("+vn+")),"+vn+")");
						}
					}
				}
				
			}
			if(mode==genSink){
				if(it->second>>3&1){
					dfsan_bad_used=1;
					plog+"sink discovered:"+src_loc-source;
					if(mtype==ie){
						if(s_ie->HasSideEffects(*Context))return;
						if(!(s_ie->getType()->isArithmeticType()||s_ie->getType()->isPointerType()))return;
						auto label=get_new_label(it->first,source,0);
						string dfsan_end='('+label+"=dfsan_get_label((long)"+r.get_source(s_ie)+"),";
						for(auto& x:{"_SaN_bad00000"}){
							sink_file_source_vars.insert(x);
							dfsan_end+="dfsanlog(\""+label+"\",\""+x+"\","+label+","+x+",dfsan_has_label(" +label+','+x+")),";
							visited_edges+label-x;
						}
						if(r.isRewritable(s_ie->getBeginLoc())&&r.isRewritable(s_ie->getEndLoc())){
							auto err=r.InsertBefore(s_ie,dfsan_end)||r.InsertTextAfterToken(s_ie->getEndLoc(),")");
							assert(!err);
						} else plog-"sink not accessible";
						return;
					}
				}
				else if(it->second>>1&1){
					plog+"sink discovered:"+src_loc-source;
					if(mtype==ie){
						if(s_ie->HasSideEffects(*Context))return;
						if(!(s_ie->getType()->isArithmeticType()||s_ie->getType()->isPointerType()))return;
						auto label=get_new_label(it->first,source,0);
						string dfsan_end='('+label+"=dfsan_get_label((long)"+r.get_source(s_ie)+"),";
						for(auto& x:sink_labels[it->first]){
							sink_file_source_vars.insert(x);
							dfsan_end+="dfsanlog(\""+label+"\",\""+x+"\","+label+","+x+",dfsan_has_label(" +label+','+x+")),";
							visited_edges+label-x;
						}
						if(r.isRewritable(s_ie->getBeginLoc())&&r.isRewritable(s_ie->getEndLoc())){
							auto err=r.InsertBefore(s_ie,dfsan_end)||r.InsertTextAfterToken(s_ie->getEndLoc(),")");
							assert(!err);
						} else plog-"sink not accessible";
						return;
					}
					//data sink
					log_var_types(r.find_vars_expr(_sink_vars()));
				}
			
			}
			
		}

	}
};
}

class DfsanConsumer : public ASTConsumer
{
public:
	void Initialize(ASTContext&context) override{
		visitor.setContext(context);
		r.Context=&context;
		Matcher.addMatcher(ASTMatchModify::DeclMatcher,&astcb);
	}
	bool HandleTopLevelDecl(DeclGroupRef D){
		for(auto x:D){
			//visitor.TraverseDecl(x);
		}
		return 1;
	}
	void HandleTranslationUnit(ASTContext &context) {
		if(mode==disabled)return;
		Matcher.matchAST(context);
		bool hasPrev=0;
		if(visited.size())cerr<<visited.size()<<'/'<<interested.size()<<endl;
		for(auto& x:visited)visited_f-string(*x);
		cerr<<"labels inited:"<<[](){int rt=0;for(auto& x:dfsan_labels)rt+=x.second.size();return rt;}();
		write_labels();
		if(mode){
			string out;
			llvm::raw_string_ostream ossr(out);
			r.getEditBuffer(r.SMp->getMainFileID()).write(ossr);
			Logger ofs(full_filename+".dfsan");
			Logger liblabels(workspace+"libdfsanlabels.c",ios::app);
			ofs.ccl.push_back(&plog);
			vector<string> labelsHere;
			if(dfsan_bad_used){
				ofs-"#include <sanitizer/dfsan_interface.h>\nextern dfsan_label _SaN_bad00000;";
			}
			if(mode==genSource)ofs.ccl.push_back(&liblabels);
			for(auto& x:dfsan_labels){
				if(split2(x.first,':').first==filename){
					unique(x.second,1);
					for(auto& y:x.second)
						if(original_code.find(y)==string::npos){
						if(hasPrev)ofs<',';
						else{
							hasPrev=1;
							ofs<R"(#include <sanitizer/dfsan_interface.h>
dfsan_label )";
						}
						ofs<y;
						labelsHere+=y;
					}
				}
			}
			if(hasPrev){
				ofs-';';
				if(mode==genSource){
					ofs<"void __attribute__ ((constructor)) _dfsan_init_"+random_id()+"(){\n";
					for(auto& y:labelsHere){
						ofs<y<"=dfsan_create_label(\""<y<"\",0);\n";
					}
					ofs-"}";
				}
			}
			ofs.ccl.pop_back();
			//create extern labels
			hasPrev=0;
			for(auto& x:sink_file_source_vars){
				if(hasPrev)ofs<',';
				else{
					hasPrev=1;
					ofs<R"(#include <sanitizer/dfsan_interface.h>
extern dfsan_label )";
				}
				ofs<x;
			}
			if(hasPrev)ofs-";";
			ofs-"extern void dfsansrc(const char*source);";
			if(sink_file_source_vars.size())
				ofs-"extern void dfsanlog(const char* sink,const char* source,int ilbl,int slbl,int positive);";
			ofs.ccl.clear();
			out=regex_replace(out,regex("register "),"");//removing register variable declaration
#define MOVE_DFSAN_LABELS
#ifdef MOVE_DFSAN_LABELS
			if(mode==genSink){
				//SplitString(out,res,"\n"); llvm::SplitString ignores empty lines and breaks GNU binutils
				int lc=0;bool one=0;
				const auto process=[&](string_view x){
					if(x=="#line 1")one=1;
					if(++lc==1||one)ofs-x;
					else if(x.starts_with("dfsan_label"))ofs+"extern"-x;
				};
				if(out.back()!='\n')out.push_back('\n');
				size_t pit=-1;
				for(auto it=out.find('\n',0);it!=string::npos;it=out.find('\n',it+1)){
					process({out.data()+pit+1,it-pit-1});
					pit=it;
				}
			}
			else
#endif
			ofs-"#line 1"<out;
		}
	}
private:
	DfsanClassVisitor visitor;
	ast_matchers::MatchFinder Matcher;
	ASTMatchModify::MyASTMatcherCallBack astcb{r};
};

class MyASTAction : public PluginASTAction
{
public:
	unique_ptr<clang::ASTConsumer> CreateASTConsumer(CompilerInstance &Compiler,llvm::StringRef InFile)override{
		return unique_ptr<clang::ASTConsumer>(new DfsanConsumer());
	}
	ActionType getActionType()override{return AddBeforeMainAction;}

	bool ParseArgs(const CompilerInstance &CI, const vector<string>& args) {
		CIp=(CompilerInstance*)&CI;
		auto&SM=CI.getSourceManager();
		filename=split(SM.getFileEntryForID(SM.getMainFileID())->getName().str(),'/').back();
		full_filename=SM.getFileEntryForID(SM.getMainFileID())->tryGetRealPathName().str();
		if(filename!="conftest.c"){
			auto md=getenv("DFPG_MODE");
			if(!md)return 1;
			if(!strcmp(md,"genSource")){
				mode=genSource;
			} else if(!strcmp(md,"genSink")){
				mode=genSink;
			}
			auto ws=getenv("WORKDIR");
			if(!ws)return 1;
			workspace=ws;
			if(workspace.back()!='/')workspace.push_back('/');
			string a,b;
			for(ifstream bl(workspace+"blacklist.txt");bl>>a;){
				blacklist.insert(a);
				if(a==filename)return 1;
			}
			load_labels();
			bool foundme=0;
			for(ifstream ts(workspace+"task.txt");ts>>a>>b;){
				foundme|=split2(a,':').first==filename||split2(b,':').first==filename;
				if(a=="E:-1"||b=="E:-1"){
					if(b=="E:-1"){//uni source
						interested[{a}]|=4;
					} else{//uni sink
						interested[{b}]|=8;
					}
					continue;
				}
				interested[{a}]|=1;
				interested[{b}]|=2;
				df_edge[a].insert(b);
				if(dfsan_labels.contains(a))
					for(auto&x:dfsan_labels[a])
						sink_labels[b].insert(x);
			}
			if(!foundme){
				mode=disabled;
				return 1;
			}
			//static SingleInstance si("dfsan");
			plog.open(workspace+"plog.log",ios_base::app);
			//plog.ccl.push_back(&cerr);
			visited_f.open(workspace+"visited.txt",ios_base::app);
			visited_edges.open(workspace+"visited_edges.txt",ios::app);
		}
		auto _=ifstream(full_filename);
		original_code={(istreambuf_iterator<char>(_)),istreambuf_iterator<char>()};
		dmp(Mode_str[mode]);
		//plog<interested_points.size()<*interested_points.begin()<'\n';
		r.setSourceMgr(CI.getSourceManager(),CI.getLangOpts());
		return true;
	}
};

static clang::FrontendPluginRegistry::Add<MyASTAction>
X("DfsanPlugin", "DFsan Plugin");

//ref: https://llvm.org/docs/WritingAnLLVMPass.html
#include<llvm/Pass.h>
#include "llvm/IR/Module.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
namespace llvm_experimental{
using namespace llvm;
Logger llog("/tmp/llog.log");
struct DfsanPass:ModulePass{
	static char ID;
	DfsanPass(): ModulePass(ID) {}
	virtual bool runOnModule(llvm::Module& M) override{
		auto x=M.begin();
		return 0;
		for(auto& F : M) {
			dmp(&F);
			/*for(auto& B : F) {
				dmp(&B);
				for(auto& I : B) {
				}
			}*/
		}
		return 0;
	}
};
char DfsanPass::ID=0;
#if 1
static RegisterPass<DfsanPass> X("DFSan","DFSan Pass",
	false /* Only looks at CFG */,
	false /* Analysis Pass */);
static RegisterStandardPasses Y(
	PassManagerBuilder::EP_EarlyAsPossible,
	[](const PassManagerBuilder& Builder,
		legacy::PassManagerBase& PM) { PM.add(new DfsanPass()); });
#endif
}
