. _go.sh
{
cd $APP
rm -rf $WORKDIR/cov
mkdir -p $WORKDIR/cov
$configure
if false; then # dep asan
	export DFSAN_HEADPARA=' -fsanitize=address -fsanitize-coverage=edge,no-prune,trace-pc-guard'
	export ASAN_OPTIONS="coverage=1:coverage_dir=$WORKDIR/cov" 
	make -j8
	. $AHOME/../benchmark/test-$APP.sh ||. $AHOME/../benchmark/make-check.sh
	cd $WORKDIR/cov
	ls *.sancov |xargs -I{} -P 16 sh -c "sancov -symbolize {} $APPBIN >{}.json"
	ls *.sancov |xargs -I{} -P 16 sh -c "sancov -symbolize {} $APPBIN |python3 $AHOME/covjson2fl.py >{}.fl"
	sort -u *.fl > $WORKDIR/covfl.txt
else
	#generally preferred, less dependencies
	export DFSAN_HEADPARA=' -fprofile-instr-generate -fcoverage-mapping'
	make -j8
	export LLVM_PROFILE_FILE="$WORKDIR/cov/%p.praw"
	. $AHOME/../benchmark/test-$APP.sh ||. $AHOME/../benchmark/make-check.sh
	cd $WORKDIR
	chmod -R 777 cov
	set -x
	llvm-profdata merge -sparse cov/*.praw -o cov/profdata
	llvm-cov report $APPBIN -instr-profile=cov/profdata
	llvm-cov report $APPBIN -instr-profile=cov/profdata > coverage.txt
fi
}
#python3 -m tclib telegram "covdone$APP"
