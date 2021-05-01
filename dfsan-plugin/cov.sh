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
	export SOURCE_COV=1
	make -j8
	export LLVM_PROFILE_FILE="$WORKDIR/cov/%p.praw"
	$AHOME/../benchmark/test-$APP.sh || $AHOME/../benchmark/make-check.sh || true
	cd $WORKDIR
	chmod -R 777 cov
	#llvm-profdata merge -sparse cov/*.praw -o cov/profdata
	#llvm-cov report $APPBIN -instr-profile=cov/profdata
	#llvm-cov report $APPBIN -instr-profile=cov/profdata > coverage.txt
	pushd cov
	if [ -n "$SOURCEMAIN" ]; then
		mkdir -p trash
		for f in ./*.praw; do
		llvm-profdata merge -sparse  $f -o  profdata &&llvm-cov report $WORKDIR/$APPBIN -instr-profile=profdata 2>/dev/null|grep $SOURCEMAIN |grep -P " 0.00\%"| while read line; do mv $f trash; done
		done
	fi
	ls|wc -l
	if [ -n "$SOURCEMAIN" ]; then
		ls trash|wc -l
	fi
	y=''
	for f in ./*.praw; do
		y="$y $f"
		llvm-profdata merge -sparse  $y -o  profdata &&llvm-cov report $WORKDIR/$APPBIN -instr-profile=profdata 2>/dev/null|tail -n1 |awk '{print $NF}' >> covratio.txt
	done
fi
}
#python3 -m tclib telegram "covdone$APP"
exit
#y=''
# for x in open('nz.txt'):
# 	x=x.split()[0]
# 	y+=x+' '
# 	print(f'llvm-profdata merge -sparse  {y} -o  profdata &&llvm-cov report $APPBIN -instr-profile=profdata 2>/dev/null|grep sort. ')
