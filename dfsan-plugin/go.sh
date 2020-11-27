. _go.sh
{
cd $APP
export DFPG_MODE=genSource
$configure
# -fvisibility=hidden -fsanitize=safe-stack,cfi -flto -fcf-protection -fstack-protector-all
export DFSAN_HEADPARA=" $DFSAN_HEADPARA -L$WORKDIR -ldfsanlabels -L$AHOME -ldfsan-rt -w -I$INCLUDE -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt\
 -Xclang -load -Xclang $AHOME/dfsan-plugin.so -Xclang -add-plugin -Xclang DfsanPlugin"
> $WORKDIR/visited.txt;make clean;make $MAKEARGS
python3 $AHOME/replace.py
echo '_____________genSink_______________'>>$WORKDIR/plog.log
export DFPG_MODE=genSink
make clean;make $MAKEARGS
python3 $AHOME/replace.py
popd
clang-11 -shared -fPIC libdfsanlabels.c -o libdfsanlabels.a
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
python3 -m tclib ifttt done$APP 2>/dev/null ||true
