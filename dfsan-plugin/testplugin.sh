make
AHOME=$(pwd)
clang-11 -std=c++20 -I../include -lstdc++ \
-Xclang -load -Xclang $AHOME/plugin-test.so -Xclang -add-plugin -Xclang PluginTest \
a.cpp
