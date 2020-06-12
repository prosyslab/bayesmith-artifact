export LLVM_VIRT=/tmp/llvm-project/virtualroot
export PATH=$LLVM_VIRT/bin:$PATH
export LD_LIBRARY_PATH=$LLVM_VIRT/lib:$LD_LIBRARY_PATH
cp dfsan-inject/openssl-list.txt /tmp/openssl-list.txt
