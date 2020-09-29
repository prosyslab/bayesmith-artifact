#include<bits/stdc++.h>
#include<tianyichen/std.h>
using namespace tianyichen::std;
map<string,int>id;
vector<vector<int>>e;
int getid(const string&s){
	if(id.contains(s))return id[s];
	int i=id[s]=id.size();
	if(e.size()<i+1)e.emplace_back();
	return id[s];
}
void sample_path_len(){
	mt19937_64 mt;
	int total=0;
	for(int i=0;i<10000;++i){
		int x=mt()%e.size();
		while(e[x].size()){
			++total;
			x=e[x][mt()%e[x].size()];
		}
	}
	printf("avg path length: %lf\n",total/10000.);
}
int main(int argc,char**argv){
	assert(argc==2);
	e.reserve(2048);
	freopen(argv[1],"r",stdin);
	string buf;
	while(getline(cin,buf)){
		buf=split2(buf,": ").second;
		auto d=split(buf,", ");
		if(d.size()<2){
			//R0: TrueBranch(setup_replacement-66877,setup_replacement-66898)
			continue;
		}
		auto to=getid(d.back());
		d.pop_back();
		for(auto& x:d){
			int i=getid(x.substr(4));
			e[i].push_back(to);
		}
	}
	dmp(e.size());
	int total_edges=0;
	for(auto& x:e)total_edges+=x.size();
	printf("total edges: %d\n",total_edges);
	sample_path_len();
}