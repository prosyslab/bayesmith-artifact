#include<bits/stdc++.h>
using namespace std;
int main(int argc,char** argv){
	ostringstream call;
	auto use_afl=getenv("USE_AFL");
	call<<(use_afl&&*use_afl=='1'?"afl-clang":"clang-11");
	if(auto HEAD_PARA=getenv("DFSAN_HEADPARA");HEAD_PARA){
		call<<HEAD_PARA;
	}
	ostringstream linkargs;
	for(int i=1;i<argc;++i){
		if(!strcmp(argv[i],"-Werror"))continue;
		(argv[i][1]&&strcmp("-load",argv[i])&&(!memcmp(argv[i],"-l",2)||!memcmp(argv[i],"-L",2))?
			linkargs:call)<<' '<<quoted(argv[i]);
	}
	return system((call.str()+linkargs.str()).data())>>8;//linux
}