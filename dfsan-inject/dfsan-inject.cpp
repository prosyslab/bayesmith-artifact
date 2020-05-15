#include<iostream>
#include<string>
#include<vector>
#include<fstream>
#include<regex>
#include<unordered_set>
#include"lclang.h"
#include"FriendlyRewriter.h"
#include"RawFileManager.h"
#include"ExtraHeaders.h"

using namespace clang;
using namespace clang::driver;
using namespace clang::tooling;
using namespace tianyichen::std;
using namespace FriendlyClangUtility;

static llvm::cl::OptionCategory ToolingSampleCategory("Tooling Sample");

using ofileloc=string;//in format abc.c:123
string output,patch;
ofstream patch_f;
RawFileManager rfm;
unordered_set<int> processed;
unordered_multimap<ofileloc,int> interested;//src,dst
unordered_map<ofileloc,set<ofileloc>> df_edge;
unordered_map<ofileloc,set<string>> sink_labels;
ExtraHeaders extra_headers("_SaN_");
Logger plines("/tmp/plines.log");
namespace ASTMatchModify{
using namespace clang::ast_matchers;
StatementMatcher DeclMatcher=anyOf(
	binaryOperator(
		anyOf(hasOperatorName("="),hasOperatorName("|="),hasOperatorName("+="))
	).bind("binop"),
	ifStmt().bind("ifstmt"),
	callExpr().bind("callexp")
);
void init(){
}
map<string,set<string>> extra_vars_by_file;
void generate_extra_patches(){
	map<string,int>cnt;
	for(auto&x:extra_vars_by_file){
		for(auto&y:x.second)++cnt[y];
		string dfsan_vars=R"(#include <sanitizer/dfsan_interface.h>
#include <assert.h>
dfsan_label )";
		bool hasPrev=0;
		for(auto&y:x.second){
			if(hasPrev)dfsan_vars+=',';
			dfsan_vars+=y;
			hasPrev=1;
		}
		dfsan_vars+="\n;void __attribute__ ((constructor)) _dfsan_init_"+extra_headers.get_identifier()+"(){\n";
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

}
struct MyASTMatcherCallBack:MatchFinder::MatchCallback{
	ASTContext *Context;
	FriendlyRewriter&r;
	string query_src_loc(SourceLocation loc,bool lineonly=true){
		auto fs=loc.printToString(*r.SMp);
		int cnt=0;
		auto a=fs.rfind('/');
		auto b=fs.rfind(':');
		fs=fs.substr(a+1,b-a-1);
		plines<fs<'\n';
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
		erase_if(rt,var_filter);
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
		erase_if(rt,var_filter);
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
		if(!FS)return;

		if(!r.IsInMainFile(FS))return;

		auto ln=SM.getExpansionLineNumber(FS->getBeginLoc());
		auto lnend=SM.getExpansionLineNumber(FS->getEndLoc());
		assert(SM.getExpansionLineNumber(FS->getBeginLoc())==SM.getSpellingLineNumber(FS->getBeginLoc()));

		if(!processed.insert(ln).second)return;
		auto src_loc=query_src_loc(FS->getBeginLoc());
		auto endLoc=query_src_loc(FS->getEndLoc());
		//if(rfm.isdupfile(src_loc.substr(0,src_loc.find(':'))))return;
		if(!interested.count(src_loc))return;
		auto range=interested.equal_range(src_loc);
		if(range.first!=range.second){
			plines<<src_loc<<' '<<r.get_source(FS)<<'\n';
		}
		if(0&&range.first!=range.second){
			if(mtype==ifstmt){
				dmp(r.get_source(s_ifstmt->getCond()));
				s_ifstmt->getCond()->dumpColor();
			}else{
				dmp(r.get_source(FS));
				FS->dumpColor();
			}
			dmp(source_vars());
			dmp(sink_vars());
		}
		set<int> processed_interest;
		for(auto it=range.first;it!=range.second;++it){
			if(it->second!=phase)continue;
			if(processed_interest.contains(it->second)){
				it->second=2;
				continue;
			}
			//dmp(r.get_source(FS));
			//FS->dumpColor();
			if(it->second==0){
				//data src
				//assert(lhs); //not ture can be MemberExpr->-ImplicitCastExpr->DeclRefExpr, e.g. png_ptr->zbuf_size
				for(auto& varname:source_vars()){
					auto uniq_name=extra_headers.get_identifier("dfsan_label");
					extra_vars_by_file[first_line(src_loc)].insert(uniq_name);
					//cerr<<"processing "<<ln<<' '<<uniq_name<<'\n';
					extra_headers.add_line(uniq_name+"=dfsan_create_label(\""+uniq_name+"\",0);");
					auto dfsan_begin="\ndfsan_set_label("+uniq_name+",&"+varname+",sizeof("+varname+"));\n";

					if(mtype!=binop){
						r.InsertBefore(FS,dfsan_begin);
						plines<"source if|call::"<ln<' '<lnend<'\n';
						patch_f<<'{'<<dfsan_begin<<"/*ifstmt|callexp*/\n"<<"before "<<src_loc<<'\n';
						patch_f<<"}\n"<<"after "<<endLoc<<'\n';
					}else{
						plines<"source binop\n";
						//patch_f<<"//InsertAfterSemi::"<<r.get_source(FS)<<'::'<<dfsan_begin<<'\n';
						r.InsertAfterSemi(FS,dfsan_begin);
						patch_f<<dfsan_begin<<"/*binexp*/\n"<<"after "<<src_loc<<endl;
					}
					for(auto&x:df_edge[src_loc]){
						sink_labels[x].insert(uniq_name);
					}
				}

			}else if(it->second==1){
				//data sink
				//dmp(r.get_source(FS));

				for(auto&varname:sink_vars()){
					auto label=extra_headers.get_identifier();
					extra_vars_by_file[first_line(src_loc)].insert(label);
					//; at the beginning is for closing goto labels
					string dfsan_end="\n;dfsan_label "+label+"=dfsan_get_label((long)"+varname+");";
					for(auto&x:sink_labels[src_loc]){
						dfsan_end+=R"(
printf(__FILE__ "[%d] %s %s %d\n" ,__LINE__,")"+label+"\",\""+x+"\",dfsan_has_label(" +label+','+x+"));";
					}
					//dmp(dfsan_end);
					//patch_f<<dfsan_end<<"\nbefore "<<src_loc<<'\n';
					r.InsertBefore(FS,dfsan_end);
				}
			}
			processed_interest.insert(it->second);
			it->second=2;//processed
		}

	}
};
}

struct MyASTConsumer: public ASTConsumer {
	MyASTConsumer(FriendlyRewriter &R):R{R},/*Visitor(R),*/astcb(R){
		Matcher.addMatcher(ASTMatchModify::DeclMatcher,&astcb);
	}
	void HandleTranslationUnit(ASTContext &Context) override {
		Matcher.matchAST(Context);
		astcb.phase=1;processed.clear();
		cerr<<"=====================================================================\n";
		Matcher.matchAST(Context);
	}
private:
	//MyASTVisitor Visitor;
	FriendlyRewriter&R;
	ast_matchers::MatchFinder Matcher;
	ASTMatchModify::MyASTMatcherCallBack astcb;
};

struct MyFrontendAction: ASTFrontendAction{
	FriendlyRewriter TheRewriter;
	void EndSourceFileAction() override{
		SourceManager &SM = TheRewriter.getSourceMgr();
		ofstream ofs(output);
		string out;
		llvm::raw_string_ostream ossr(out);
		TheRewriter.getEditBuffer(SM.getMainFileID()).write(ossr);
		ofs<<"#include <sanitizer/dfsan_interface.h>\n";
		ofs<<"#include <assert.h>\n";
		extra_headers.add_line("}");
		extra_headers.write(ofs);

		ofs<<ossr.str();
	}
	std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI,
		StringRef file) override {
		extra_headers.add_line("void __attribute__ ((constructor)) _dfsan_init_(){");

		CI.getDiagnostics().setClient(new IgnoringDiagConsumer());
		TheRewriter.setSourceMgr(CI.getSourceManager(),CI.getLangOpts());
		return make_unique<MyASTConsumer>(TheRewriter);
	}
};

int main(int argc,const char** argv){
	cerr<<__cplusplus<<endl;
	ios::sync_with_stdio(0);
	cin>>output>>patch;
	patch_f.open(patch);
	string a,b;
	while(cin>>a>>b){
		interested.emplace(a,0);
		interested.emplace(b,1);
		df_edge[a].insert(b);
	}

	ASTMatchModify::init();

	CommonOptionsParser op(argc,argv,ToolingSampleCategory);
	rfm.load(op.getSourcePathList()[0]);
	ClangTool Tool(op.getCompilations(),op.getSourcePathList());
	auto rt=Tool.run(newFrontendActionFactory<MyFrontendAction>().get());

	auto visited=count_if(interested.begin(),interested.end(),[](auto &p){return p.second==2;});
	if(visited!=interested.size()){
		for(auto&x:interested){
			if(x.second!=2){
				//cout<<"miss "<<x.first<<' '<<x.second<<'\n';
				//dmp(rfm.get_source(x.first));
			}
		}
	}
	ASTMatchModify::generate_extra_patches();
	cerr<<"coverage: " <<visited<<'/'<<interested.size()<<'\n'<<endl;
	return rt;
}
