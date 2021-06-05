LLVM_ROOT=$PWD/../llvm/
export AHOME=$PWD/dfsan-plugin
export UHOME=$PWD/utils
ulimit -c 0
ln -s $LLVM_ROOT /tmp/llvm-project
if [ -f /.dockerenv ]; then
	:
else
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
#export BINGO_CI=$PWD/../vanilla-experiment/
export VANILLA_CI=$PWD/../vanilla-experiment/
export BENCHMARKi=(bc-1.06 cflow-1.5 grep-2.19 gzip-1.2.4a libtasn1-4.3 patch-2.7.1 readelf-2.24 sed-4.3 sort-7.2 tar-1.28 )
export BENCHMARKt=(latex2rtf-2.1.1 optipng-0.5.3 shntool-3.0.5)
export BENCHMARKa=("${BENCHMARKi[@]}" "${BENCHMARKt[@]}")
pushd ~/nichrome/ >/dev/null
  export NICHROME_HOME=`pwd`
popd >/dev/null