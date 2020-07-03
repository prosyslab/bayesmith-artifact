. _go.sh
{
cd $APP
mkdir -p $WORKDIR/cov
$configure
export DFSAN_HEADPARA=' -fsanitize=address -fsanitize-coverage=edge,no-prune,trace-pc-guard'
make -j8
export ASAN_OPTIONS="coverage=1:coverage_dir=$WORKDIR/cov" 
. $AHOME/../benchmark/test-$APP.sh
cd $WORKDIR/cov
ls *.sancov |xargs -I{} -P 16 sh -c "sancov -symbolize {} $APPBIN |python3 $AHOME/covjson2fl.py >{}.fl"
sort -u *.fl > $WORKDIR/covfl.txt
}
python3 -m tclib ifttt "covdone$APP"
