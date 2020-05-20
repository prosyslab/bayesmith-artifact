#include<bits/stdc++.h>
#include<tianyichen/std.h>
#include<FriendlyRewriter.h>
#include<clang/Frontend/FrontendPluginRegistry.h>

#include"lclang.h"

using namespace tianyichen::std;
using namespace clang;
using namespace clang::ast_matchers;
using namespace llvm;

string filename;
FriendlyRewriter r;
CompilerInstance* CIp;
Logger plog("/tmp/plugintest.log");
class MyClassVisitor : public RecursiveASTVisitor<MyClassVisitor>
{
private:
	ASTContext *context;
public:
	void setContext(ASTContext &context)
	{
		this->context = &context;
	}

	bool VisitIntegerLiteral(IntegerLiteral*s){
		return 1;
	}

	bool VisitVarDecl(VarDecl*d){
		return 1;
	}
	bool VisitFunctionDecl(FunctionDecl* d){
		return 1;
	}
	bool VisitStmt(Stmt*s){
		if(!r.IsInMainFile(s))return 1;
		return 1;
	}

};
namespace ASTMatchModify{
StatementMatcher DeclMatcher=anyOf(
	binaryOperator(
		anyOf(hasOperatorName("="),hasOperatorName("|="),hasOperatorName("+="))
	).bind("binop"),
	//ifStmt().bind("ifstmt"),
	callExpr().bind("callexp")
);
struct MyASTMatcherCallBack:MatchFinder::MatchCallback{
	ASTContext *Context;
	FriendlyRewriter&r;
	int phase=0;
	MyASTMatcherCallBack(FriendlyRewriter&rewriter):r{rewriter}{}

	void run(const MatchFinder::MatchResult &Result){
		Context= Result.Context;
		r.Context=Context;
		auto&SM=Context->getSourceManager();
		if(auto s_binop=Result.Nodes.getNodeAs<BinaryOperator>("binop");s_binop){
			if(!r.IsInMainFile(s_binop))return;
			//s_binop->dumpColor();
			auto res=r.find_vars_expr_raw(s_binop->getRHS());
			PrintingPolicy dp(CIp->getLangOpts());
			plog-"vartypes:";
			for(auto x:res){
				x->dumpColor();
				plog-make_pair(r.get_source(x),x->getType().getAsString(dp));
			}
		}
	}
};
}

class MyConsumer : public ASTConsumer
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
		Matcher.matchAST(context);
	}
private:
	MyClassVisitor visitor;
	ast_matchers::MatchFinder Matcher;
	ASTMatchModify::MyASTMatcherCallBack astcb{r};
};

class MyASTAction : public PluginASTAction
{
public:
	virtual unique_ptr<clang::ASTConsumer> CreateASTConsumer(CompilerInstance &Compiler,
													llvm::StringRef InFile)
	{
		return unique_ptr<clang::ASTConsumer>(new MyConsumer());
	}
	virtual ActionType getActionType(){return AddBeforeMainAction;}

	bool ParseArgs(const CompilerInstance &CI, const
					std::vector<std::string>& args) {
		CIp=const_cast<CompilerInstance*>(&CI);
		auto&SM=CI.getSourceManager();
		filename=SM.getFileEntryForID(SM.getMainFileID())->getName().str();
		cerr<<"ParseArgs: "<<filename<<endl;
		r.setSourceMgr(CI.getSourceManager(),CI.getLangOpts());
		return true;
	}
};

static clang::FrontendPluginRegistry::Add<MyASTAction>
X("PluginTest", "DFsan Plugin");
