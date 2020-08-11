LLVM_VER=11
CPP=clang-$(LLVM_VER)
FLAGS= -w -O2 -std=c++20 -fPIC -isystem../include
LCPP= -lstdc++ -lm
### building from official packages

# ICLANG=-isystem/usr/lib/llvm-$(LLVM_VER)/include/ #-I/usr/lib/llvm-11/include/c++/v1
# LCLANG=-L/usr/lib/llvm-$(LLVM_VER)/lib/ -lclangToolingCore -lclangTooling -lclangFrontendTool -lclangFrontend -lclangDriver -lclangSerialization -lclangCodeGen -lclangParse -lclangSema -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangAnalysis -lclangARCMigrate -lclangRewrite -lclangRewriteFrontend -lclangEdit -lclangAST -lclangLex -lclangBasic -lclangASTMatchers -fno-rtti  -lstdc++ -lm

###building
ifndef LLVM_VIRT
$(error LLVM_VIRT is not set)
endif
ICLANG=-isystem$(LLVM_VIRT)/include
LCLANG=-L$(LLVM_VIRT)/lib -lclangToolingCore -lclangTooling -lclangFrontendTool -lclangFrontend -lclangDriver -lclangSerialization -lclangCodeGen -lclangParse -lclangSema -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangAnalysis -lclangARCMigrate -lclangRewrite -lclangRewriteFrontend -lclangEdit -lclangAST -lclangLex -lclangBasic -lclangASTMatchers -fno-rtti $(LCPP)

all:dfsan-plugin.so plugin-test.so clang-dfsan libdfsan-rt.a interactive-feedback graphtun
dfsan-plugin.so:dfsan-plugin.cpp #*.h
	$(CPP) $(FLAGS) $(ICLANG) -shared $? -o $@ $(LCLANG)
interactive-feedback:interactive-feedback.cpp
	$(CPP) $(FLAGS) -fsanitize=address $? -o $@ $(LCPP)
plugin-test.so:plugin-test.cpp #*.h 
	$(CPP) $(FLAGS) $(ICLANG) -shared $? -o $@ $(LCLANG)
test:test.cpp
	$(CPP) $(FLAGS)  test.cpp -o test $(LCLANG)
graphtun:graphtun.cpp
	$(CPP) $(FLAGS) $? -o $@ $(LCPP)
clang-dfsan:clang-dfsan.cpp
	$(CPP) $(FLAGS) $? -o $@ $(LCLANG)
	#ln -fs clang-dfsan g++
	#ln -fs clang-dfsan gcc
	#ln -fs clang-dfsan cc
libdfsan-rt.a: dfsan-rt.cpp
	$(CPP) $(FLAGS) $(ICLANG) -DLLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1 -shared $? -o $@ $(LCLANG)
clean:
	echo $(PATH)
	rm dfsan-plugin.so plugin-test.so clang-dfsan *.a
