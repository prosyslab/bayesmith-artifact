if [ -f /.dockerenv ]; then
	:
else
	ln -s ~/Desktop/llvm/ /tmp/llvm-project
fi
export LLVM_VIRT=/tmp/llvm-project/virtualroot
export PATH=$PWD/dfsan-plugin:$LLVM_VIRT/bin:$PATH
export LD_LIBRARY_PATH=$LLVM_VIRT/lib:$LD_LIBRARY_PATH
export DFSAN_OPTIONS=warn_unimplemented=0
cp dfsan-inject/openssl-list.txt /tmp/openssl-list.txt
export PYTHONHASHSEED=0
