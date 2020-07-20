/*
interactive feedback
input: feedback.txt
output: interact with driver.py in bingo
*/
#define TAG "Int100filtered"
#include<tianyichen/std.h>
#include<unistd.h>
using namespace tianyichen::std;
Logger Log("/tmp/inter" TAG ".log");
vector<pair<string,string>> feedbacks;
using feedit=decltype(feedbacks.begin());
bool good(){
#define TEMPFILE "/tmp/ranktmp" TAG
	unlink(TEMPFILE);
	puts("BP 1e-6 500 1000 100");
	puts("P " TEMPFILE);
	fflush(stdout);
	for(int cnt=0;!cnt;){
		this_thread::sleep_for(1s);
		ifstream ti(TEMPFILE);
		string tmp;
		int nancnt=0;
		while(ti>>tmp){
			dmp(tmp);
			++cnt;
			if(tmp=="nan")++nancnt;
		}
		if(nancnt)Log-nancnt,Log.flush();
		if(nancnt)return 0;
	}
	return 1;
}
int success;
void try_add(feedit b,feedit e){
	if(e-b<100)return;//discard small
	Log+__FUNCTION__+(b-feedbacks.begin())-(e-feedbacks.begin());Log.flush();
	if(e==b)return;
	if(e-b==1){
		printf("O %s %s\n",b->first.data(),b->second.data());fflush(stdout);
		if(!good()){
			printf("UC %s\n",b->first.data());fflush(stdout);
		}else ++success;
		return;
	}
	auto mid=(e-b)/2+b;
	for(auto i=b;i<e;++i)printf("O %s %s\n",i->first.data(),i->second.data());
	fflush(stdout);
	if(good()){
		success+=e-b;
		return;
	}
	for(auto i=b;i<e;++i)printf("UC %s\n",i->first.data());
	fflush(stdout);
	try_add(b,mid);
	try_add(mid,e);
}
int main(){
	Log.ccl.push_back(&cerr);
	string _,a,b;
	freopen("/tmp/tr/feedback.txt","r",stdin);
	Log-"start";Log.flush();
	while(cin>>_>>a>>b&&feedbacks.size()<2000){
		assert(b=="true"||b=="false");
		feedbacks.emplace_back(a,b);
	}
	//partition(feedbacks.begin(),feedbacks.end(),[](pair<string,string>& a){return a.second[0]=='t';});
	try_add(feedbacks.begin(),feedbacks.end());
	Log+"success"-success;
	puts("AC 1e-6 500 1000 100 stats.txt " TAG "combined out");fflush(stdout);
}