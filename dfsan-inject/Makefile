LLVM_VER=11
CPP=clang-$(LLVM_VER)
# -stdlib=libc++  
FLAGS= -std=c++2a -O2 -g -I../include -Wno-ambiguous-reversed-operator
ICLANG=-isystem /usr/lib/llvm-$(LLVM_VER)/include/ #-I/usr/lib/llvm-11/include/c++/v1
LCLANG=-L/usr/lib/llvm-$(LLVM_VER)/lib/ -lLLVM -lclangToolingCore -lclangTooling -lclangFrontendTool -lclangFrontend -lclangDriver -lclangSerialization -lclangCodeGen -lclangParse -lclangSema -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangAnalysis -lclangARCMigrate -lclangRewrite -lclangRewriteFrontend -lclangEdit -lclangAST -lclangLex -lclangBasic -lclangASTMatchers -lclang -fno-rtti -lstdc++ -lm
all:dfsan-inject
dfsan-inject:dfsan-inject.cpp *.h
	$(CPP) $(FLAGS) $(ICLANG) dfsan-inject.cpp -o dfsan-inject $(LCLANG)

clean:
	rm dfsan-inject
