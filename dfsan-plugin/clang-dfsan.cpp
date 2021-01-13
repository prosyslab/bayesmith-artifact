#include<bits/stdc++.h>
#include<tianyichen/std.h>
using namespace tianyichen::std;
string_view get_outputname(int argc,char**argv){
	for(int i=1;i<argc-1;++i){
		if(!strcmp(argv[i],"-o"))return argv[i+1];
	}
	return {};
}
int main(int argc,char** argv){
	Logger l("/tmp/clang_dfsan.log",ios::app);
	ostringstream call;
	auto use_afl=getenv("USE_AFL");
	call<<(use_afl&&*use_afl=='1'?"afl-clang":"clang-11");
	if(auto HEAD_PARA=getenv("DFSAN_HEADPARA");HEAD_PARA){
		call<<HEAD_PARA;
	}
	if(getenv("SOURCE_COV")&&(
		!getenv("COVBINFILTER")||
		(getenv("COVBINFILTER")&&split(string_view{getenv("COVBINFILTER")},'/').back()==get_outputname(argc,argv)))){
		call<<" -fprofile-instr-generate -fcoverage-mapping";
	}
	ostringstream linkargs;
	for(int i=1;i<argc;++i){
		if(!strcmp(argv[i],"-Werror"))continue;
		(argv[i][1]&&strcmp("-load",argv[i])&&(!memcmp(argv[i],"-l",2)||!memcmp(argv[i],"-L",2))?
			linkargs:call)<<' '<<quoted(argv[i]);
	}
	//linkargs<<" -lstdc++";
	l+call.str()-linkargs.str();
	return system((call.str()+linkargs.str()).data())>>8;//linux
}
