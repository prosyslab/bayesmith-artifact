/*
Linux specific code
Copyright (C) Tianyi Chen, 2020
Conforms to the C++20 standard
*/
#ifdef __linux__
#pragma once
#include<sys/file.h>
#include<string>
namespace tianyichen::std{
Logger Cerr("/dev/stderr");
struct SingleInstance{
	int fh;
	SingleInstance(::std::string name){
		fh = open(("/tmp/"+name+".pid").data(), O_CREAT | O_RDWR, 0666);
		flock(fh, LOCK_EX);
	}
	~SingleInstance(){
		flock(fh,LOCK_UN);
	}
};
}
#endif
