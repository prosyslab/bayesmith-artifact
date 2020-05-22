/*
FriendlyRewriter, a friendly wrapper and extension for clang::Rewriter
Copyright (C) Tianyi Chen, 2018
Conforms to the C++2a standard
*/
#pragma once
#include<string>
#include<iostream>
#include<cassert>
#include<unordered_set>
#include<string_view>
#include<variant>
#include"tianyichen/std.h"
#include"clang/AST/AST.h"
#include"clang/AST/ASTConsumer.h"
#include"clang/AST/ASTContext.h"
#include"clang/AST/RecursiveASTVisitor.h"
#include"clang/ASTMatchers/ASTMatchers.h"
#include"clang/ASTMatchers/ASTMatchFinder.h"
#include"clang/Frontend/ASTConsumers.h"
#include"clang/Frontend/CompilerInstance.h"
#include"clang/Frontend/FrontendActions.h"
#include"clang/Rewrite/Core/Rewriter.h"
#include"clang/Tooling/CommonOptionsParser.h"
#include"clang/Tooling/Tooling.h"
#include"clang/Tooling/Core/Replacement.h"
#include"llvm/Support/CommandLine.h"
#include"llvm/Support/raw_ostream.h"
namespace _FriendlyRewriterImpl{
using namespace std;
using namespace clang;
using namespace llvm;
struct FriendlyRewriter:Rewriter{
	SourceManager*SMp;
	const LangOptions*LOp;
	ASTContext* Context;
	FriendlyRewriter(){}
	FriendlyRewriter(SourceManager&SM,const LangOptions&LO):
		SMp(&SM),LOp(&LO),Rewriter(SM,LO){}
	void setSourceMgr(SourceManager&SM,const LangOptions&LO){
		SMp=&SM;LOp=&LO;
		Rewriter::setSourceMgr(SM,LO);
	}
	static Stmt* _last_child(Stmt*s){
		if(s->child_begin()==s->child_end())
			return 0;
		for(auto i=s->child_begin(),j=i;;++i){
			if(i==s->child_end())return *j;
			j=i;
		}
	}
	static const Stmt* _last_child(const Stmt*s){
		return _last_child(const_cast<Stmt*>(s));
	}
	template<class T>
	static bool _is_a(const Stmt*s){
		if(isa<T>(s))return 1;
		if(s->child_begin()!=s->child_end())
			return _is_a<T>(_last_child(s));//which is the last child
		return isa<T>(s);
	}
	template<class T>
	string get_source(const T *s){
		return Lexer::getSourceText(CharSourceRange(s->getSourceRange(),1),*SMp,{}).str();
	}
	string get_source(SourceRange s){
		return Lexer::getSourceText(CharSourceRange(s,1),*SMp,{}).str();
	}
	bool IsInMainFile(clang::SourceLocation Loc){
		return SMp->isWrittenInMainFile(Loc);
	}
	template<class T,class=enable_if_t<is_base_of_v<Stmt,T>||is_base_of_v<Decl,T>>>
	bool IsInMainFile(const T*s){
		return IsInMainFile(s->getEndLoc());
	}
	auto InsertBefore(const Stmt*s,llvm::StringRef Str){
		return InsertTextBefore(s->getBeginLoc(),Str);
	}
	auto InsertBefore(const Decl*s,llvm::StringRef Str){
		return InsertTextBefore(s->getSourceRange().getBegin(),Str);
	}
	auto InsertAfter(const Stmt*s,llvm::StringRef str){
		//cerr<<"\033[31m"<<get_source(s)<<"\033[0m\n";
		if(_is_a<CompoundStmt>(s)||_is_a<NullStmt>(s)){
			//it works
			return InsertTextAfter(s->getEndLoc().getLocWithOffset(1),str);
		} else{
			auto nx_token_o=Lexer::findNextToken(s->getEndLoc(),*SMp,*LOp);
			auto&nx_token=nx_token_o.getValue();
			return InsertTextAfter(s->getEndLoc().getLocWithOffset(nx_token.getLength()),str);
		}
	}
	//insert after semicolumn
	auto InsertAfterSemi(const Stmt*s,llvm::StringRef str){
		auto end=s->getEndLoc();
		while(get_source({end,end})!=";"){
			end=end.getLocWithOffset(1);
		}
		return InsertTextAfter(end.getLocWithOffset(1),str);
	}
	[[deprecated]]int get_ln_semi(const Stmt*s){
		auto end=s->getEndLoc();
		while(get_source({end,end})!=";"){
			end=end.getLocWithOffset(1);
		}
		return SMp->getExpansionLineNumber(end);
	}
	auto InsertAfter(const VarDecl*s,llvm::StringRef str){
		//source range is complete
		//nevertheless, another token is essential
		auto nx_token_o=Lexer::findNextToken(s->getEndLoc(),//
			*SMp,*LOp);
		auto&nx_token=nx_token_o.getValue();
		return InsertTextBefore(nx_token.getLastLoc(),str);
	}
	auto next_token(SourceLocation loc){
		return Lexer::findNextToken(loc,*SMp,*LOp).getValue();
	}
	template<class SD,class T>
	auto Replace(SD*s,T sr){
		return ReplaceText(s->getSourceRange(),sr);
	}
	auto Remove(Stmt*s){
		return RemoveText(s->getSourceRange());
	}
	bool wrap(const string&before,const Stmt*s,const string&after){
		return InsertBefore(s,before)||InsertAfter(s,after);
	}
	void dump(SourceLocation sr){
		sr.dump(*SMp);
	}
	SourceRange pop_back(SourceRange sr){
		//undefined if begin==end
		SourceLocation prev_loc;
		auto token=Lexer::findNextToken(sr.getBegin(),*SMp,*LOp).getValue();
		if(token.getLastLoc()==sr.getEnd()){
			//single token stub
			return {sr.getBegin(),sr.getBegin()};
		}
		int i=0;
		while(1){
			int j=0;
			if(++i==1000)throw 0;
			/*
			getLastLoc->get the real last position
			getEndLoc->get the location AFTER the token, which is INCONSISTENT with the design of most parts
			*/
			auto ce=token.getLastLoc();
			//cerr<<"processing"<<get_source({sr.getBegin(),ce})<<endl;
			//getLastLoc seems to point to an incorrect loc, probably
			//ce.dump(*SMp);
			//sr.getEnd().dump(*SMp);
			if(ce==sr.getEnd())
				return {sr.getBegin(),prev_loc};
			prev_loc=ce;
			//getLocation??->works
			token=Lexer::findNextToken(token.getLocation(),*SMp,*LOp).getValue();
		}
	}
	auto find_vars_expr(const clang::Expr* e){
		using namespace clang;
		using namespace std;
		set<Expr*> rt;
		//static tianyichen::std::Logger l("/tmp/std.log",ios_base::app);
		const function<void(const Expr*)> dfs=[&](const auto e){
			//toggies for only non struct types
			if(auto f=dyn_cast<MemberExpr>(e);f){
				if(!f->getType().getTypePtr()->isStructureType())
					rt.insert((Expr*)f);
				return;
			}
			if(auto f=dyn_cast<DeclRefExpr>(e);f){
				if(!dyn_cast<FunctionDecl>(f->getDecl())){
					if(f->isLValue()&&!f->getDecl()->getType().getTypePtr()->isStructureType())
						rt.insert((Expr*)f);
				}
			}
			for(auto x:e->children()){
				dfs((const Expr*)x);
			}
		};
		dfs(e);
		return rt;
	}
	[[deprecated]]auto __find_vars_type_expr(const clang::Expr* e){
		using namespace clang;
		using namespace std;
		map<string,string> rt;
		const function<void(const Expr*)> dfs=[&](const auto e){
			if(auto f=dyn_cast<MemberExpr>(e);f){
				rt.emplace(get_source(f),f->getType().getAsString());
				return;
			}
			if(auto f=dyn_cast<DeclRefExpr>(e);f){
				if(!dyn_cast<FunctionDecl>(f->getDecl())){
					rt.emplace(f->getNameInfo().getName().getAsString(),f->getDecl()->getType().getAsString());
				}
			}
			for(auto x:e->children()){
				dfs((const Expr*)x);
			}
		};
		dfs(e);
		return rt;
	}
};
}
namespace FriendlyClangUtility{
bool starts_with(const std::string_view v,const std::string_view r){
	return v.substr(0,r.size())==r;
}
bool IsDefaultConstruction(clang::VarDecl*d){
	if(auto c=llvm::dyn_cast<clang::CXXConstructExpr>(d->getInit())){
		return c->child_begin()==c->child_end();
	}
	return 0;
}
/*
bool BelongsTemplateType(clang::VarDecl*v,std::string_view name){
	return starts_with(v->getType().getCanonicalType().getAsString(),name);
}
*/
#define BelongsTemplateType(v,name) \
	FriendlyClangUtility::starts_with(v->getType().getCanonicalType().getAsString(),name "<")
using descendants_t=std::unordered_set<std::variant<clang::Stmt*,clang::Decl*>>;
template<class T>
T pop_front(T r){
	if(r.begin()==r.end())return r;
	auto b=++r.begin();
	return {b,r.end()};
}
template<class T>
T pop_back(T r){
	if(r.begin()==r.end())return r;
	return {r.begin(),--r.end()};
}
template<class T>
void descendants(T*s,descendants_t&st){
	using namespace std;
	clang::Stmt*body;
	cerr<<"decendents"<<s<<endl;
	if constexpr(is_same_v<clang::DeclStmt,T>){
		body=s;
		for(auto d:((clang::DeclStmt*)s)->getDeclGroup()){
			st.insert(d);
			descendants(d,st);
		}
	}else if constexpr(is_base_of_v<clang::Stmt,T>){
		body=s;
	}else if constexpr(is_base_of_v<clang::Decl,T>){
		if(s->hasBody())body=s->getBody();
		else return;
	} else assert(0);
	for(auto x:body->children()){
		st.insert(x);
		descendants(x,st);
	}
}

}
using FriendlyRewriter=_FriendlyRewriterImpl::FriendlyRewriter;
