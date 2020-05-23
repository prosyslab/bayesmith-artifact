/*
std.h, extension for the standard library
Copyright (C) Tianyi Chen, 2018-2020
Conforms to the C++17 standard
*/
#pragma once
#include<vector>
#include<chrono>
#include<mutex>
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include<iostream>
#include<set>
#include<unordered_set>
#include<map>
#include<random>
#include<string_view>
#if __has_include("llvm/ADT/StringRef.h")
#define _TIANYICHEN_HAS_LLVM
#include "llvm/ADT/StringRef.h"
#endif
namespace tianyichen::std{
using namespace ::std;
template<class T>
void unique(vector<T>&v,bool Sort=1){
	if(Sort)sort(v.begin(),v.end());
	v.erase(unique(v.begin(),v.end()),v.end());
}
//unordered map<string*,pointed_hash,pointed_eq>
struct pointed_eq{
	template<class T>
	bool operator()(T*const a,T*const b)const{
		return *a==*b;
	}
};
struct pointed_hash{
	template<class T>
	bool operator()(const T* a)const{
		return ::std::hash<T>{}(*a);
	}
};
template<class T>
auto ptrcpy(T*to,T*from){
	return memcpy(to,from,sizeof *to);
}
template<class T>
bool range_nonempty(const T&r){
	return r.begin()!=r.end();
}
template<class T>
auto&operator+=(vector<T>&v,const T&i){
	v.emplace_back(i);return v;
}
string random_id(int len=16){
	string rt;
	static mt19937 mt(random_device{}());
	for(int i=0;i<len;++i)rt.push_back("qwertyuioplkjhgfdsazxcvbnm"[mt()%26]);
	return rt;
}
#define dmp(x) std::cerr<<#x<<' '<<x<<'\n'
#define DUM(x) #x<' '<x<'\n'
template<class C>
auto& _ostream_ls(ostream&o,const C&c,char b='['){
	bool hasPrev=0;
	o<<b;
	for(const auto&x:c){
		if(hasPrev)o<<',';
		o<<x;
		hasPrev=1;
	}
	switch (b){
		case'{':o<<'}';break;
		default:o<<']';break;
	}
	return o;
}
template<class T,class V>
auto map_keys(const map<T,V>&m){
	set<T> rt;
	for(auto&x:m)rt.insert(x.first);
	return rt;
}
template<class T,class V>
auto map_keys(const multimap<T,V>&m){
	set<T> rt;
	for(auto&x:m)rt.insert(x.first);
	return rt;
}
#ifdef _TIANYICHEN_HAS_LLVM
ostream& operator<<(ostream& o,llvm::StringRef c){ return o<<c.data(); }
#endif
template<class T,class V>ostream& operator<<(ostream&o,const pair<T,V>& c){return o<<'<'<<c.first<<','<<c.second<<'>';}
template<class T>ostream& operator<<(ostream&o,const set<T>& c){return _ostream_ls(o,c);}
template<class T>ostream& operator<<(ostream&o,const unordered_set<T>& c){return _ostream_ls(o,c);}
template<class T>ostream& operator<<(ostream&o,const vector<T>& c){return _ostream_ls(o,c);}
struct Logger:ofstream{
	using ofstream::ofstream;
	vector<ostream*>ccl; //CC list
	template<class T>
	auto& operator<<(const T&v){
		(ofstream&)*this<<v;
		for(auto&x:ccl)*x<<v;
		return *this;
	}
	template<class T>
	auto& operator<(const T&v){
		*this<<v;
		return *this;
	}
	template<class T>
	auto& operator+(const T&v){
		*this<v<' ';
		return *this;
	}
	template<class T>
	auto& operator-(const T&v){
		*this<v<'\n';
		return *this;
	}
};

#ifdef _MSC_VER
#define _STD_CPP_FUNCTION_NAME __FUNCTION__
#else//g++, clang
#define _STD_CPP_FUNCTION_NAME __PRETTY_FUNCTION__
#endif
//time a scope duration
#define TIMEME static const char*const _STD_FUNCTION_NAME=_STD_CPP_FUNCTION_NAME;\
static struct _ittime_{\
mutex mx;double t=0;\
~_ittime_(){\
	cerr<<_STD_FUNCTION_NAME<<' '<<t<<'\n';\
}\
}_ittime_var;\
struct time_class{\
	chrono::high_resolution_clock::time_point t1=chrono::high_resolution_clock::now();\
	~time_class(){\
		chrono::high_resolution_clock::time_point t2=chrono::high_resolution_clock::now();\
		lock_guard<mutex>(_ittime_var.mx);\
		_ittime_var.t+=chrono::duration_cast<chrono::duration<double>>(t2 - t1).count();\
	}\
}___;
int atoi(string_view s){
	int rt=0;bool neg=0;
	for(char x:s){
		if(isdigit(x))rt=rt*10+x-'0';
		else if(x=='-')neg=!neg;
		else break;
	}
	return neg?-rt:rt;
}
template<class A,class B,class C>
bool between(A a,B low,C high){
	return low<=a&&a<=high;
}
template<class T,class V>
pair<T,T> split2(const T&c,const V&v){
	auto sep=find(c.begin(),c.end(),v);
	if(sep==c.end())return make_pair(c,T{});
	return make_pair(T{c.begin(),sep},T{sep+1,c.end()});
}
template<class S>
inline auto& string_append(S&s){
	return s;
}
//more efficient than s+=a+b+c...
template<class S,class T,class...R>
inline auto& string_append(S&s,const T&t,R...r){
	s.append(t);return string_append(s,r...);
}
auto&split_pop_front(string&s){
	auto p=s.find(' ');
	if(p==string::npos)return s;
	return s=s.substr(p);
}
template<class...T>struct vtuple{};
template<class T,class...R>
struct vtuple<T,R...>:vtuple<R...>{
	T v;
	vtuple(){}
	vtuple(const T&vv,R...args):v(vv),vtuple<R...>(args...){}
	using vtuple<R...>::operator=;
	T&operator=(const T&r){
		return v=r;
	}
	explicit operator T&(){
		return v;
	}
	template<class U>
	explicit operator U&(){
		return vtuple<R...>::operator U &();
	}
	bool operator<(const vtuple<T,R...>&r)const{
		if(v<r.v)return 1;
		if(r.v<v)return 0;
		return vtuple<R...>::operator<(vtuple<R...>(r));
	}
};
template<class...T>struct vtuple_implicit{};
template<class T,class...R>
struct vtuple_implicit<T,R...>:vtuple_implicit<R...>{
	T v;
	using vtuple_implicit<R...>::operator=;
	vtuple_implicit(){}
	vtuple_implicit(const T&vv,R...args):v(vv),vtuple_implicit<R...>(args...){}
	T&operator=(const T&r){
		return v=r;
	}
	template<class U>
	T&operator=(U r){
		return v=r;
	}
	operator T&(){
		return v;
	}
	template<class U>
	operator U&(){
		return vtuple_implicit<R...>::operator U &();
	}
	bool operator<(const vtuple_implicit<T,R...>&r)const{
		if(v<r.v)return 1;
		if(r.v<v)return 0;
		return vtuple_implicit<R...>::operator<(vtuple_implicit<R...>(r));
	}
};
}
