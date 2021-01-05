. _go.sh
{
mkdir -p asan
cd $APP
export ASAN_OPTIONS=detect_leaks=0
$configure
#clang-11 -shared -fPIC libdfsanlabels.c -o libdfsanlabels.a
# -fvisibility=hidden -fsanitize=safe-stack,cfi -flto -fcf-protection -fstack-protector-all
export DFSAN_HEADPARA=" $DFSAN_HEADPARA -fsanitize=address -w -I$INCLUDE -L$AHOME -lrt"
> $WORKDIR/visited.txt;make clean;make $MAKEARGS
make $MAKEARGS
#python3 $AHOME/../dfsan-inject/applyPatch.py $WORKDIR/$APP
pushd $WORKDIR/$APP
unset DFPG_MODE
make clean
make $MAKEARGS
cd $WORKDIR/$APP/
>$WORKDIR/san.log
mkdir -p $WORKDIR/dfg # even single threaded execution leads interfere
. $AHOME/../benchmark/test-$APP.sh ||. $AHOME/../benchmark/make-check.sh
#cat $WORKDIR/dfg/*txt > $WORKDIR/dfgraph.txt # mysterious 000
sudo chmod -R 777 $WORKDIR
popd
#python3 $AHOME/san2fileline.py $WORKDIR
}