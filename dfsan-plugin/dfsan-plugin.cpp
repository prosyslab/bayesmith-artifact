#include<bits/stdc++.h>
#include<tianyichen/std.h>
#include<ranges>
#include<FriendlyRewriter.h>
#include"lclang.h"
#include"clang/Frontend/FrontendPluginRegistry.h"

using namespace tianyichen::std;
using namespace clang;
using namespace clang::ast_matchers;

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
Logger loc_vars,plog,visited_f;
string filename,full_filename;
using ofileloc=string;
unordered_map<ofileloc,set<ofileloc>> df_edge;
unordered_map<ofileloc,set<string>> sink_labels;
map<FileLine,int>interested;
set<const FileLine*>visited;
set<string>sink_file_source_vars;
//>>0&1, source
//>>1&1, sink

map<string,vector<string>>dfsan_labels;
int dfsan_id_used;
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
string get_new_label(string loc){
	auto rt="_SaN_"+to_string(++dfsan_id_used+((mode-1)*10000));
	dfsan_labels[loc].push_back(rt);
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
class ToyClassVisitor : public RecursiveASTVisitor<ToyClassVisitor>
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
StatementMatcher DeclMatcher=
anyOf(
	binaryOperator(
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
		binop,
		ifstmt,
		callexp,
		vardecl,
		invalid,
	}mtype;
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
				if(mtype==binop)visited.insert(&x.first);
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
		if(!FS){
			s_ifstmt=Result.Nodes.getNodeAs<IfStmt>("ifstmt");
			if(s_ifstmt)FS=s_ifstmt,mtype=ifstmt;
		}
		if(!FS){
			s_callexp=Result.Nodes.getNodeAs<CallExpr>("callexp");
			if(s_callexp)FS=s_callexp,mtype=callexp;
		}
		if(!FS){
			if(s_vardecl=Result.Nodes.getNodeAs<VarDecl>("vardecl"))
			{
				//s_vardecl->getinit
			}
		}
		if(mtype==invalid)return;
		if(!FS||!r.IsInMainFile(FS))return;
		//if(!processed.insert(ln).second)return;
		auto src_loc=query_src_loc(FS->getBeginLoc());
		auto endLoc=query_src_loc(FS->getEndLoc());
		plog.ccl.clear();
		plog+"match discovered "+src_loc-endLoc;
		if(!IsInterestingPair(src_loc,endLoc))return;
		plog+"is interesting "+src_loc-endLoc;
		plog.ccl.push_back(&cerr);
		plog+FS->getBeginLoc().printToString(*r.SMp)-FS->getEndLoc().printToString(*r.SMp);
		plog+"src:"-r.get_source(FS);
		auto range=make_pair(interested.lower_bound({src_loc}),
			interested.upper_bound({endLoc}));
		dmp(make_pair(src_loc,endLoc));
		dmp(make_pair(range.first->first,range.second->second));
		for(auto it=range.first;it!=range.second;++it){
			//FS->dumpColor();
			if(it->second&1&&mode==genSource){
				//data src
				//assert(lhs); //not ture can be MemberExpr->-ImplicitCastExpr->DeclRefExpr, e.g. png_ptr->zbuf_size
				for(auto& varname:source_vars()){
					plog+"source"<DUM(varname);
					auto uniq_name=get_new_label(it->first);
					if(mtype!=binop){
						plog+"usource:"+int(mtype)+src_loc-endLoc;
					}else if(mtype==binop){
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
						//auto dfsan_begin="DFSET("
						//	+r.get_source(s_binop->getLHS())+','+
						//	r.get_source(s_binop->getRHS())+','+uniq_name+")";
						//r.ReplaceText(FS->getSourceRange(),dfsan_begin);
						//plog-"after_replace"-r.get_source(FS)-dfsan_begin;
						r.InsertBefore(FS,"(");
						r.InsertTextAfterToken(FS->getEndLoc(),
							",dfsan_set_label("+uniq_name+",&"+vn+",sizeof("+vn+")),"+vn+")");
					}
				}

			}
			if(it->second>>1&1&&mode==genSink){
				//data sink
				plog+"sink discovered:"-src_loc;
				for(auto&varname:sink_vars()){
					plog+"sink"<DUM(varname);
					//; at the beginning is for closing goto labels
					if(sink_labels[it->first].empty())continue;
					auto label=get_new_label(it->first);
					if(r.get_source(varname).empty()){
						plog-"ASSERT0";
						varname->dump();
						continue;
					}
					//each variable keeps as variable
					if(mtype==binop){
						string dfsan_end=label+"=dfsan_get_label((long)"+r.get_source(varname)+"),";
						for(auto& x:sink_labels[it->first]){
							sink_file_source_vars.insert(x);
							dfsan_end+=R"(printf(__FILE__ "[%d] %s %s %d\n" ,__LINE__,")"+label+"\",\""+x+"\",dfsan_has_label(" +label+','+x+")),";
						}
						dmp(dfsan_end);
						plog+"dfsan_end"-dfsan_end;
						r.InsertBefore(FS,dfsan_end);
					} else if(mtype==callexp){
						string dfsan_end='('+label+"=dfsan_get_label((long)"+r.get_source(varname)+"),";
						for(auto& x:sink_labels[it->first]){
							sink_file_source_vars.insert(x);
							dfsan_end+=R"(printf(__FILE__ "[%d] %s %s %d\n" ,__LINE__,")"+label+"\",\""+x+"\",dfsan_has_label(" +label+','+x+")),";
						}
						dmp(dfsan_end);
						plog+"dfsan_end"-dfsan_end;

						if(r.isRewritable(varname->getBeginLoc())&&r.isRewritable(varname->getEndLoc())){
							auto err=r.InsertBefore(varname,dfsan_end)||r.InsertTextAfterToken(varname->getEndLoc(),")");
							assert(!err);
						} else plog-"sink not accessible";
					}else {
						plog+"usink:"+int(mtype)+src_loc-endLoc;
					}
				}
				log_var_types(r.find_vars_expr(_sink_vars()));
			}
		}

	}
};
}

class ToyConsumer : public ASTConsumer
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
			ofs.ccl.push_back(&plog);
			vector<string> labelsHere;
			for(auto& x:dfsan_labels){
				if(split2(x.first,':').first==filename){
					for(auto& y:x.second)
						if(y.size()<=9&&mode==genSource||y.size()>9&&mode==genSink){//_san_9999
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
			if(sink_file_source_vars.size()&&out.find("stdio.h")==string::npos)
				ofs-"extern int printf(const char *format, ...);";

			ofs.ccl.clear();
			ofs-"#line 1"<out;
		}
	}
private:
	ToyClassVisitor visitor;
	ast_matchers::MatchFinder Matcher;
	ASTMatchModify::MyASTMatcherCallBack astcb{r};
};

class MyASTAction : public PluginASTAction
{
public:
	unique_ptr<clang::ASTConsumer> CreateASTConsumer(CompilerInstance &Compiler,llvm::StringRef InFile)override{
		return unique_ptr<clang::ASTConsumer>(new ToyConsumer());
	}
	ActionType getActionType()override{return AddBeforeMainAction;}

	bool ParseArgs(const CompilerInstance &CI, const vector<string>& args) {
		CIp=(CompilerInstance*)&CI;
		auto&SM=CI.getSourceManager();
		filename=SM.getFileEntryForID(SM.getMainFileID())->getName().str();
		if(filename=="css_.c")return 1;
		if(filename!="conftest.c"){
			auto md=getenv("DFPG_MODE");
			if(!md)return 1;
			auto ws=getenv("WORKDIR");
			if(!ws)return 1;
			workspace=ws;
			if(workspace.back()!='/')workspace.push_back('/');
			load_labels();
			if(!strcmp(md,"genSource")){
				mode=genSource;
			}else if(!strcmp(md,"genSink")){
				mode=genSink;
			}
			ifstream ts(workspace+"task.txt");
			string a,b;
			while(ts>>a>>b){
				interested[{a}]|=1;
				interested[{b}]|=2;
				df_edge[a].insert(b);
				if(dfsan_labels.contains(a))
					for(auto&x:dfsan_labels[a])
						sink_labels[b].insert(x);
			}
			plog.open(workspace+"plog.log",ios_base::app);
			plog.ccl.push_back(&cerr);
			visited_f.open(workspace+"visited.txt",ios_base::app);
		}
		full_filename=SM.getFileEntryForID(SM.getMainFileID())->tryGetRealPathName().str();
		plog<DUM(full_filename);
		dmp(Mode_str[mode]);
		dmp(full_filename);
		//plog<interested_points.size()<*interested_points.begin()<'\n';
		r.setSourceMgr(CI.getSourceManager(),CI.getLangOpts());
		return true;
	}
};

static clang::FrontendPluginRegistry::Add<MyASTAction>
X("DfsanPlugin", "DFsan Plugin");
