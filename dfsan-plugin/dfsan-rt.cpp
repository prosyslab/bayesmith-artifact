#include<bits/stdc++.h>
#include<tianyichen/std.h>
using namespace tianyichen::std;
namespace dfsan_rt{
Logger log;
extern "C" void dfsanlog(const char* sink,const char* source,int positive){
	//TIMEME;
	//if(!positive)return;
	if(!strcmp(sink,source))return;
	static set<tuple<string,string,int>> printed;
	auto _=log.acquire_lock();
	if(printed.emplace(make_tuple(string(sink),string(source),positive)).second)
		log+sink+source-positive;
}
extern "C" void dfsansrc(const char* source){
	static set<string> printed;
	auto _=log.acquire_lock();
	if(printed.emplace(source).second)
		log+source-2;
}
bool working=1;
void limiter(){
	auto start=time(0);
	while(working){
		this_thread::yield();
		if(time(0)-start>60)abort();
	}
}
struct TimeLimit{
	TimeLimit(){
		thread(limiter).detach();
		auto wd=getenv("WORKDIR");
		if(!wd)return;
		log.open(string{wd}+"/san.log",ios::app);
	}
	~TimeLimit(){
		working=0;
	}
}_;
}