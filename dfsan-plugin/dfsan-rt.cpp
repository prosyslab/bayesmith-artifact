#include<bits/stdc++.h>
#include<tianyichen/std.h>
using namespace tianyichen::std;
extern "C" void dfsanlog(const char* sink,const char* source,int positive){
	//TIMEME;
	auto wd=getenv("WORKDIR");
	if(!wd)return;
	static Logger log(string{wd}+"/san.log",ios::app);
	if(!positive||!strcmp(sink,source))return;
	static set<pair<string,string>> printed;
	if(printed.emplace(make_pair(string(sink),string(source))).second)
		log+sink+source-positive;
}
