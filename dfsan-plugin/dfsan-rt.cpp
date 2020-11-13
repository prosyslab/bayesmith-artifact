#include<bits/stdc++.h>
#include<tianyichen/std.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <unistd.h>
using namespace tianyichen::std;
extern "C"  void dfsan_dump_labels(int fd);
namespace dfsan_rt{
int pid;
Logger log;
Logger slog;
int seq;auto seq2=new int(0);
auto start=time(0);
extern "C" void dfsanlog(const char* sink,const char* source,int ilbl,int slbl,int positive){
	//TIMEME;
	//if(!positive)return;
	if(!strcmp(sink,source))return;
	if(!slbl)return;//the source memory does not have label
	static set<tuple<string,string,int>> printed;
	auto _=log.acquire_lock();
	if(printed.emplace(make_tuple(string(sink),string(source),positive)).second)
		((log<pid<'.')+(++seq)+sink+source+ilbl+slbl-positive).flush();
}
extern "C" void dfsansrc(const char* source){
	static set<string> printed;
	auto _=log.acquire_lock();
	if(printed.emplace(source).second)
		((log<pid<'.')+(++seq)+source-2).flush();
}
bool working=1;
void limiter(){
	auto start=time(0);
	while(working){
		this_thread::yield();
		if(time(0)-start>60){
			Cerr-"Killed by dfsan-rt";
			sync();
			abort();
		}
	}
}
int argc;char** argv;char** envp;
static void dump_target_state(int _argc, char* _argv[], char* _envp[]){
	argc=_argc;
	argv=_argv;
	envp=_envp;
}

__attribute__((section(".init_array"))) void (* p_dump_target_state)(int,char*[],char*[]) = &dump_target_state;
char buffer[BUFSIZ];

struct TimeLimit{
	TimeLimit(){
		pid=getpid();
		thread(limiter).detach();
		auto wd=getenv("WORKDIR");
		if(!wd)return;
		log.open(string{wd}+"/dfg/"+to_string(pid)+"san.log");
		slog.open(string{wd}+"/dfg/"+to_string(pid)+"run.log");
		slog-"argv:";
		for(int i=0;i<argc;++i)slog-argv[i];
		string peek;
		//setbuf(stdin, buffer);
		//peek.push_back(cin.peek());
#ifdef DFSAN_EXTRACT_STDIN
		for(int i=0;i<10;++i){
			auto c=getchar();
			if(c!=EOF)peek.push_back(c);
			else break;
		}
		slog-"stdin:"+peek.size()<"<<<"<peek;
		slog-">>>";
		for(auto i=peek.rbegin();i!=peek.rend();++i)ungetc(*i,stdin);
#endif
		slog-"envp:";
		for (char **env = envp; *env != 0; env++){
			char *thisEnv = *env;
			slog-thisEnv;
		}
		log+"start"+pid-std::chrono::high_resolution_clock::now().time_since_epoch().count();
	}
	~TimeLimit(){
		if(!working){
			log-"DESTRUCTOR_INTEGRITY_CHECK_FAILED";
			log.flush();
		}
		working=0;
		assert(working==0);
		auto wd=getenv("WORKDIR");
		if(!wd)return;
		auto f=fopen((string{wd}+"/dfg/"+to_string(pid)+"dfg.txt").data(),"w");
		fprintf(f,"DFGRAPH %d\n",pid);fflush(f);//required to switch to fd
		dfsan_dump_labels(fileno(f));//posix
		fputs("END\n",f);
		log+"end"+pid-std::chrono::high_resolution_clock::now().time_since_epoch().count();
		log.close();
	}
}_;
}