#include<bits/stdc++.h>
using namespace std;
int main(int argc,char** argv){
	ostringstream call;call<<"clang-11";
	ostringstream linkargs;
	for(int i=1;i<argc;++i){
		(argv[i][1]&&strcmp("-load",argv[i])&&(!memcmp(argv[i],"-l",2)||!memcmp(argv[i],"-L",2))?
			linkargs:call)<<' '<<quoted(argv[i]);
	}
	return system((call.str()+linkargs.str()).data())>>8;//linux
}