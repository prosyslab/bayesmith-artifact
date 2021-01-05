. _go.sh
{
cd $APP
mkdir -p $WORKDIR/cov
$configure
if true; then # dep asan
else
fi
export DFSAN_HEADPARA=' -fsanitize=address -fsanitize-coverage=edge,no-prune,trace-pc-guard'
export ASAN_OPTIONS="coverage=1:coverage_dir=$WORKDIR/cov" 
make -j8
. $AHOME/../benchmark/test-$APP.sh ||. $AHOME/../benchmark/make-check.sh
cd $WORKDIR/cov
ls *.sancov |xargs -I{} -P 16 sh -c "sancov -symbolize {} $APPBIN >{}.json"
ls *.sancov |xargs -I{} -P 16 sh -c "sancov -symbolize {} $APPBIN |python3 $AHOME/covjson2fl.py >{}.fl"
sort -u *.fl > $WORKDIR/covfl.txt
}
#python3 -m tclib telegram "covdone$APP"
