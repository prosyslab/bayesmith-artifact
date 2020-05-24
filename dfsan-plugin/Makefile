LLVM_VER=11
CPP=clang-$(LLVM_VER)
# -stdlib=libc++  
#FLAGS= -w -std=c++2a -O2 -g -fPIC -I../include #+10s
FLAGS= -w -O2 -std=c++20 -g -fPIC -isystem../include
ICLANG=-isystem/usr/lib/llvm-$(LLVM_VER)/include/ #-I/usr/lib/llvm-11/include/c++/v1
LCLANG=-L/usr/lib/llvm-$(LLVM_VER)/lib/ -lLLVM -lclangToolingCore -lclangTooling -lclangFrontendTool -lclangFrontend -lclangDriver -lclangSerialization -lclangCodeGen -lclangParse -lclangSema -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangStaticAnalyzerCore -lclangAnalysis -lclangARCMigrate -lclangRewrite -lclangRewriteFrontend -lclangEdit -lclangAST -lclangLex -lclangBasic -lclangASTMatchers -lclang -fno-rtti -lstdc++ -lm
all:dfsan-plugin.so plugin-test.so
dfsan-plugin.so:dfsan-plugin.cpp #*.h
	$(CPP) $(FLAGS) $(ICLANG) -shared $? -o $@ $(LCLANG)

plugin-test.so:plugin-test.cpp #*.h
	$(CPP) $(FLAGS) $(ICLANG) -shared $? -o $@ $(LCLANG)
test:test.cpp
	$(CPP) $(FLAGS)  test.cpp -o test $(LCLANG)
clang-dfsan:clang-dfsan.cpp
	$(CPP) $(FLAGS) $? -o $@ $(LCLANG)
install:clang-dfsan
	sudo cp clang-dfsan /usr/bin/
clean:
	rm dfsan-plugin.so plugin-test.so
