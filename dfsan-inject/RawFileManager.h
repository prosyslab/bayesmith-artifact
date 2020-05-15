#include"tianyichen/std.h"

namespace _RawFileManagerImpl{
using namespace tianyichen::std;
struct RawFileManager{
	struct Line{
		int rawloc,ofileloc;
		string_view filename;
		void dump(){
			cerr<<filename<<' '<<ofileloc<<' '<<rawloc<<endl;
		}
	};
	vector<Line> src_line;
	map<string,
		vector<int>//points to index of src_line
	> loc2seg;
	vector<string> raw_file{1};

	void load(string filename){
		raw_file.reserve(65536);
		ifstream ifs(filename);
		string line,ofilename;
		int linen,rawloc=0;
		while(getline(ifs,line)){
			++rawloc;
			raw_file.emplace_back(line);
			if(!line.starts_with("#line"))continue;
			linen=stoi(line.substr(5));
			if(line.find('"')!=string::npos){
				if(line.find('/')!=string::npos){
					auto a=line.rfind('/')+1,b=line.rfind('"');
					ofilename=line.substr(a,b-a);
				}else{
					auto a=line.find('"')+1,b=line.rfind('"');
					ofilename=line.substr(a,b-a);
				}
				dup_map[ofilename].insert(line.substr(line.find('"')));
				loc2seg[ofilename].push_back(src_line.size());
			}
			src_line.emplace_back(Line{rawloc,linen,loc2seg.find(ofilename)->first.data()});
		}
	}
	map<string,set<string>>dup_map;
	set<string>visited;
	bool isdupfile(string s){//skip sparrow ambigious
		if(!visited.contains(s)){
			visited.insert(s);
			cout<<s<<' '<<dup_map[s]<<endl;
		}
		return dup_map[s].size()>1;
	}
	//returns in format "abc.c:1"
	[[deprecated]]string query_src_loc(int rawloc)const{
		Line best_loc{0,0,""};
		for(auto&x:src_line){
			if(x.rawloc>best_loc.rawloc&&x.rawloc<=rawloc){
				best_loc=x;
			}
		}
		string rt{best_loc.filename};
		return rt+=':'+to_string(best_loc.ofileloc);
	}
	//finds the source code corresponding to "abc.c:1"
	string_view get_source(string_view src_loc)const{
		auto colon=src_loc.find(':');
		auto file=src_loc.substr(0,colon);
		auto ln=atoi(src_loc.substr(colon+1).data());
		Line best_loc{0,0,""};
		for(auto&x:src_line){
			if(x.filename==file&&x.ofileloc>best_loc.ofileloc&&x.ofileloc<=ln){
				best_loc=x;
			}
		}
		assert(best_loc.rawloc);
		return raw_file[best_loc.rawloc+1];
	}
};
}

using RawFileManager=_RawFileManagerImpl::RawFileManager;
