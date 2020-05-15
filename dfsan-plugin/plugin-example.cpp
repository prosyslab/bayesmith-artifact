#include<bits/stdc++.h>
#include<tianyichen/std.h>
#include<FriendlyRewriter.h>
#include "clang/Frontend/FrontendPluginRegistry.h"

#include <clang/AST/AST.h>
#include <clang/AST/ASTConsumer.h>
#include <clang/AST/ASTContext.h>
#include <clang/AST/RecursiveASTVisitor.h>
#include <clang/ASTMatchers/ASTMatchers.h>
#include <clang/ASTMatchers/ASTMatchFinder.h>
#include <clang/Frontend/ASTConsumers.h>
#include <clang/Frontend/CompilerInstance.h>
#include <clang/Frontend/FrontendActions.h>
#include <clang/Rewrite/Core/Rewriter.h>
#include <clang/Tooling/CommonOptionsParser.h>
#include <clang/Tooling/Tooling.h>
#include <clang/Tooling/Core/Replacement.h>
#include <llvm/Support/CommandLine.h>
#include <llvm/Support/raw_ostream.h>

using namespace tianyichen::std;
using namespace clang;

namespace
{
	FriendlyRewriter TheRewriter;
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
			if(!first){
				cerr<<"initing"<<first<<"\n";
				first=s;
			}else{
			   return 1;
				first->dump();
				s->dumpColor();
				 cerr<<"assign\n";
				memcpy(s,first,sizeof(IntegerLiteral));
			}
			return true;
		}

		bool VisitVarDecl(VarDecl*d){
			if(auto f=dyn_cast<ParmVarDecl>(d);f)return 1;
			if(TheRewriter.IsInMainFile(d)){
				auto V=APInt(32,42,true);
				dmp(context);
				if(first){
					auto liter=IntegerLiteral::Create(*TheRewriter.Context,V,context->IntTy,SourceLocation());
					cerr<<"set init\n";
					//d->dumpColor();
					//first->dump();
					d->setInit(liter);
					//d->dumpColor();
				}
				return 1;
			}
			return 1;
		}
		bool VisitFunctionDecl(FunctionDecl* d){
			static Stmt* putsStmt;
			if(!TheRewriter.IsInMainFile(d))return 1;
			auto body=dyn_cast<CompoundStmt>(d->getBody());
			if(body){
				auto bf=body->body_front();
				if(bf)
					bf->dumpColor();
				if(TheRewriter.get_source(bf).find("puts")!=string::npos){
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
			//s->dumpColor();
			return 1;
		}
		
	};
	
	class ToyConsumer : public ASTConsumer
	{
	public:
		void Initialize(ASTContext&context) override{
			visitor.setContext(context);
			TheRewriter.Context=&context;
		}
		bool HandleTopLevelDecl(DeclGroupRef D){
			for(auto x:D){
				dmp(x);
				visitor.TraverseDecl(x);
			}
			return 1;
		}
		void HandleTranslationUnit(ASTContext &context) {
		}
	private:
		ToyClassVisitor visitor;
	};

	class ToyASTAction : public PluginASTAction
	{
	public:
		virtual unique_ptr<clang::ASTConsumer> CreateASTConsumer(CompilerInstance &Compiler,
													  llvm::StringRef InFile)
		{
			return unique_ptr<clang::ASTConsumer>(new ToyConsumer);
		}
		virtual ActionType getActionType(){return AddBeforeMainAction;}

		bool ParseArgs(const CompilerInstance &CI, const
					   std::vector<std::string>& args) {
			TheRewriter.setSourceMgr(CI.getSourceManager(),CI.getLangOpts());
			std::cerr<<__FUNCTION__<<endl;
			return true;
		}
	};
}

static clang::FrontendPluginRegistry::Add<ToyASTAction>
X("ToyClangPlugin", "Toy Clang Plugin");
