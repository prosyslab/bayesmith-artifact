#include<bits/stdc++.h>
#include<tianyichen/std.h>
#include<FriendlyRewriter.h>
#include"clang/Frontend/FrontendPluginRegistry.h"

#include"lclang.h"

using namespace tianyichen::std;
using namespace clang;
using namespace clang::ast_matchers;

CompilerInstance* CIp;
string workspace="/tmp/";
Logger loc_vars,plog,patch_f;
string filename,output,patch,full_filename;
using ofileloc=string;
unordered_map<ofileloc,set<ofileloc>> df_edge;
unordered_map<ofileloc,set<string>> sink_labels;
map<string,int>interested;
unordered_set<const string*,pointed_hash,pointed_eq>visited;
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
string get_new_label(string loc){
	auto rt="_SaN_"+to_string(++dfsan_id_used+((mode-1)<<10));
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
		static Stmt* putsStmt;
		funname_decl[d->getNameInfo().getAsString()]=d;
		//dmp(d->getNameInfo().getAsString());
		if(!r.IsInMainFile(d)){
			return 1;
		}
		if(d->getNameInfo().getAsString()=="dfsan_dummy"){
			auto bodya=dyn_cast<CompoundStmt>(d->getBody())->body_begin();
			bodya[1]->dump();
			bodya[2]->dumpColor();

		}
		if(d->getNameInfo().getAsString()!="main"){
			return 1;
		}
		auto body=dyn_cast<CompoundStmt>(d->getBody());
		if(body){
			auto bf=body->body_front();
			if(bf)
				bf->dumpColor();
			if(r.get_source(bf).find("puts")!=string::npos){
				cerr<<__LINE__<<"assigning\n";
				putsStmt=bf;

			}else{
				dmp(putsStmt);
				if(putsStmt){
					vector<Stmt*> vs;
					vs.push_back(putsStmt);
					vs.insert(vs.end(),body->body_begin(),
					body->size()+body->body_begin());
					puts("========SetStmts===========");
					auto nb=CompoundStmt::Create(*context,vs,SourceLocation(),SourceLocation());
					ptrcpy(body,nb);//*body=*nb;
					dmp(vs);
					body->setStmts(vs);
					body->dumpColor();
				}
			}
		}

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
binaryOperator(
	anyOf(hasOperatorName("="),hasOperatorName("|="),hasOperatorName("+="))
).bind("binop");
//anyOf(
	
	//,ifStmt().bind("ifstmt")
	//,callExpr().bind("callexp")
//);
map<string,set<string>> extra_vars_by_file;
/*void generate_extra_patches(){
	map<string,int>cnt;
	for(auto&x:extra_vars_by_file){
		for(auto&y:x.second)++cnt[y];
		string dfsan_vars=;
		bool hasPrev=0;
		for(auto&y:x.second){
			if(hasPrev)dfsan_vars+=',';
			dfsan_vars+=y;
			hasPrev=1;
		}
		dfsan_vars+="\n;void __attribute__ ((constructor)) _dfsan_init_"+random_id(16)+"(){\n";
		for(auto&y:x.second){
			dfsan_vars+=y+"=dfsan_create_label(\""+y+"\",0);\n";
		}
		dfsan_vars+="}\n";
		//cerr<<x.first<<' '<<x.second<<endl;
		patch_f<<dfsan_vars<<"\nbefore "<<x.first<<endl;
	}
	//currently all paths are within the same file
	for(auto&x:cnt){
		assert(x.second==1);
	}

}*/
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
		invalid,
	}mtype;
	const BinaryOperator* s_binop;
	const IfStmt* s_ifstmt;
	const CallExpr* s_callexp;
	static bool var_filter(const string&s){
		if(s.find("___")!=string::npos)return 1;
		return s=="tmp";
	}
	auto source_vars(){
		auto rt=r.find_vars_expr(_source_vars());
		dmp(rt.size());
		//erase_if(rt,var_filter);
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
	static bool IsInterestingPair(string_view loca,string_view locb){
		string_view filename=loca.substr(0,loca.find(':'));
		int a=atoi(loca.substr(1+loca.find(':')));
		int b=atoi(locb.substr(1+locb.find(':')));
		for(auto&x:interested){
			auto y=split2(x.first,':');
			if(y.first==filename&&between(atoi(y.second),a,b)){
				visited.insert(&x.first);
				plog+"interesting "+y+loca-locb;
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
		assert(mtype!=invalid);
		if(!FS||!r.IsInMainFile(FS))return;
		//if(!processed.insert(ln).second)return;
		auto src_loc=query_src_loc(FS->getBeginLoc());
		auto endLoc=query_src_loc(FS->getEndLoc());

		if(!IsInterestingPair(src_loc,endLoc))return;
		plog+FS->getBeginLoc().printToString(*r.SMp)-FS->getEndLoc().printToString(*r.SMp);
		plog+"src:"-r.get_source(FS);
		plog<DUM(src_loc.substr(0,src_loc.rfind(':')));
		plog<DUM(endLoc.substr(0,endLoc.rfind(':')));
		auto range=make_pair(interested.lower_bound(src_loc.substr(0,src_loc.rfind(':'))),
			interested.upper_bound(endLoc.substr(0,src_loc.rfind(':'))));
		for(auto it=range.first;it!=range.second;++it){
			//FS->dumpColor();
			if(it->second&1&&mode==genSource){
				//data src
				//assert(lhs); //not ture can be MemberExpr->-ImplicitCastExpr->DeclRefExpr, e.g. png_ptr->zbuf_size
				for(auto& varname:source_vars()){
					plog+"source"<DUM(varname);
					log_var_types(r.find_vars_expr_raw(_source_vars()));
					auto uniq_name=get_new_label(it->first);
					dmp((mtype==binop));
					if(mtype!=binop){
				///*		plog<"source if|call::"<src_loc<' '<endLoc<'\n';
				//		patch_f<<'{'<<dfsan_begin<<"/*ifstmt|callexp*/\n"<<"before "<<src_loc<<'\n';
				//		patch_f<<"}\n"<<"after "<<endLoc<<'\n';
				//	} else if(mtype==callexp){
				//		plog<"source callexp"<src_loc<' '<endLoc<'\n';
				//		patch_f<<'{'<<dfsan_begin<<"/*ifstmt|callexp*/\n"<<"before "<<src_loc<<'\n';
				//		patch_f<<"}\n"<<"after "<<endLoc<<'\n';*/
					}else{
						plog<"source binop\n";
						//patch_f-'{'+"before"-src_loc;
						auto dfsan_begin=",dfsan_set_label("+uniq_name+",&"+varname+",sizeof("+varname+"))";
						patch_f<dfsan_begin<"/*binexp*/\n"<"after "<endLoc<'\n';
					}
				}

			}
			if(it->second>>1&1&&mode==genSink){
				//data sink
				//dmp(r.get_source(FS));
				for(auto&varname:sink_vars()){
					plog+"sink"<DUM(varname);
					auto label=get_new_label(it->first);
					//; at the beginning is for closing goto labels
					if(sink_labels[src_loc].empty())continue;
					string dfsan_end="\n;dfsan_label "+label+"=dfsan_get_label((long)"+varname+");";
					for(auto&x:sink_labels[src_loc]){
						sink_file_source_vars.insert(x);
						dfsan_end+=R"(
printf(__FILE__ "[%d] %s %s %d\n" ,__LINE__,")"+label+"\",\""+x+"\",dfsan_has_label(" +label+','+x+"));";
					}
					plog-dfsan_end;
					patch_f<dfsan_end<"\nbefore "<src_loc<'\n';
					//r.InsertBefore(FS,dfsan_end);
					log_var_types(r.find_vars_expr_raw(_sink_vars()));	
				}
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
		cerr<<visited.size()<<' '<<interested.size()<<endl;
		dmp(dfsan_labels.size());
		write_labels();
		if(mode==genSink){
			Logger ofs(full_filename+".dfsan");
			ofs.ccl.push_back(&plog);
			vector<string> labelsHere;
			for(auto& x:dfsan_labels){
				if(split2(x.first,':').first==filename){
					for(auto& y:x.second){
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
				ofs<"void __attribute__ ((constructor)) _dfsan_init_"+random_id()+"(){\n";
				for(auto& y:labelsHere){
					ofs<y<"=dfsan_create_label(\""<y<"\",0);\n";
				}
				ofs-"}";
			}

			hasPrev=0;
			for(auto& x:sink_file_source_vars){
				if(hasPrev)ofs<',';
				else{
					hasPrev=1;
					ofs<R"(#include <sanitizer/dfsan_interface.h>
#include<stdio.h>
extern dfsan_label )";
				}
				ofs<x;
			}
			if(hasPrev)ofs+";\n";

			ofs.ccl.clear();
			string out;
			llvm::raw_string_ostream ossr(out);
			r.getEditBuffer(r.SMp->getMainFileID()).write(ossr);
			ofs<<out;
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
	virtual unique_ptr<clang::ASTConsumer> CreateASTConsumer(CompilerInstance &Compiler,
													llvm::StringRef InFile)
	{
		return unique_ptr<clang::ASTConsumer>(new ToyConsumer());
	}
	virtual ActionType getActionType(){return AddBeforeMainAction;}

	bool ParseArgs(const CompilerInstance &CI, const vector<string>& args) {
		CIp=(CompilerInstance*)&CI;
		auto&SM=CI.getSourceManager();
		filename=SM.getFileEntryForID(SM.getMainFileID())->getName().str();
		patch_f.ccl.push_back(&plog);
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
			ts>>output>>patch;
			string a,b;
			while(ts>>a>>b){
				interested[a]|=1;
				interested[b]|=2;
				df_edge[a].insert(b);
				for(auto&x:dfsan_labels[a])
					sink_labels[b].insert(x);
			}
			plog.open(workspace+"plog.log",ios_base::app);
			patch_f.open(workspace+"patch.txt",ios_base::app);
		}

		full_filename=SM.getFileEntryForID(SM.getMainFileID())->tryGetRealPathName().str();
		plog<DUM(full_filename);
		//plog<interested_points.size()<*interested_points.begin()<'\n';
		r.setSourceMgr(CI.getSourceManager(),CI.getLangOpts());
		return true;
	}
};

static clang::FrontendPluginRegistry::Add<MyASTAction>
X("DfsanPlugin", "DFsan Plugin");
