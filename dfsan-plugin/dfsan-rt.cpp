#include<bits/stdc++.h>
#include<tianyichen/std.h>
using namespace tianyichen::std;
extern "C" void dfsanlog(const char* sink,const char* source,int positive){
	//TIMEME;
	auto wd=getenv("WORKDIR");
	if(!wd)return;
	static Logger log(string{wd}+"/san.log",ios::app);
	//if(!positive)return;
	if(!strcmp(sink,source))return;
	static set<tuple<string,string,int>> printed;
	if(printed.emplace(make_tuple(string(sink),string(source),positive)).second)
		log+sink+source-positive;
}
namespace dfsan_rt{
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
	}
	~TimeLimit(){
		working=0;
	}
}_;
}