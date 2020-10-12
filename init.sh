LLVM_ROOT=/home/ubuntu/Desktop/llvm/
if [ -f /.dockerenv ]; then
	:
else
	ln -s $LLVM_ROOT /tmp/llvm-project
	ulimit -s unlimited # allow large recursion
	# executing this in docker causes segfault
fi
export LLVM_VIRT=/tmp/llvm-project/virtualroot
export PATH=$PWD:$PWD/dfsan-plugin:$LLVM_VIRT/bin:$PATH
export LD_LIBRARY_PATH=$LLVM_VIRT/lib:$LD_LIBRARY_PATH
export DFSAN_OPTIONS=warn_unimplemented=0
cp dfsan-inject/openssl-list.txt /tmp/openssl-list.txt
export PYTHONHASHSEED=0
export BINGO=$PWD/../bingo/
export BINGO_CI=$PWD/../bingo-ci-experiment/
export VANILLA_CI=$PWD/../vanilla-experiment/