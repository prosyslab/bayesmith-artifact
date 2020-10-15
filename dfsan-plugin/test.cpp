#include<tianyichen/std.h>
using namespace tianyichen::std;
map<pair<string,string>,int>t;
int main(int argc,char** argv){
	freopen(argv[1],"r",stdin);
	string buf;
	while(getline(cin,buf)){
		auto x=split(buf,' ');
		t[{x[1],x[0]}]=0;
	}
	for(auto&x:t){
		auto it=t.lower_bound({x.first.second,""});
		while(it!=t.end()&&it->first.first==x.first.second){
			if(auto j=t.find({x.first.first,it->first.second});j!=t.end())
				j->second=1;
			++it;
		}
	}
	int trans=0;
	for(auto&x:t){
		trans+=x.second;
		if(x.second&&trans<20)Cerr-x;
	}
	Cerr+"trans:"<trans<'/'<t.size()<'\n';
}