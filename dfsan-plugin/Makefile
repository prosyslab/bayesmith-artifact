LLVM_VER=11
CPP=clang-$(LLVM_VER)
# -stdlib=libc++  
#FLAGS= -w -std=c++2a -O2 -g -fPIC -I../include #+10s
FLAGS= -w -std=c++2a  -g -fPIC -I../include
ICLANG=-I/usr/lib/llvm-$(LLVM_VER)/include/ #-I/usr/lib/llvm-11/include/c++/v1
LCLANG=-L/usr/lib/llvm-$(LLVM_VER)/lib/ -lLLVM -lclangToolingCore -lclangTooling -lclangFrontendTool -lclangFrontend -lclangDriver -lclangSerialization -lclangCodeGen -lclangParse -lclangSema -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangAnalysis -lclangARCMigrate -lclangRewrite -lclangRewriteFrontend -lclangEdit -lclangAST -lclangLex -lclangBasic -lclangASTMatchers -lclang -fno-rtti -lstdc++ -lm
all:dfsan-plugin.so
dfsan-plugin.so:dfsan-plugin.cpp #*.h
	rm /tmp/plog.log ||echo >/dev/null
	$(CPP) $(FLAGS) $(ICLANG) -shared dfsan-plugin.cpp -o dfsan-plugin.so $(LCLANG)
	
clean:
	rm dfsan-plugin.so
