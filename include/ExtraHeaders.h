#include"tianyichen/std.h"
#include<ostream>
namespace _ExtraHeadersImpl{
using namespace tianyichen::std;
struct ExtraHeaders{
	string id_prefix;
	int unique_id_cnt=-1;
	ExtraHeaders()=delete;
	ExtraHeaders(const string&id_prefix):id_prefix{id_prefix}{}
	string get_identifier(const string&type={}){
		string rt=id_prefix+to_string(++unique_id_cnt);
		if(type.size())extra_variables[type].emplace_back(rt);
		return rt;
	}
	map<string,vector<string>> extra_variables;
	vector<string> lines;
	void add_line(const string&l){
		lines.emplace_back(l);
	}
	bool has()const{
		return extra_variables.size()||lines.size();
	}
	void write(ostream& o){
		for(auto&&x:extra_variables){
			o<<x.first<<' ';
			bool hasprev=0;
			for(auto&&y:x.second){
				if(hasprev)o<<',';
				hasprev=1;
				o<<y;
			}
			o<<";\n";
		}
		for(auto&&x:lines)o<<x<<'\n';
	}
};
}
using ExtraHeaders=_ExtraHeadersImpl::ExtraHeaders;
