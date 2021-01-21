#$1 app name
#example: sort-7.2
#sudo chmod -R 777 /tmp/$1
taint=true
mkdir -p /tmp/$1/dfg/disabled/
for i in {1..9}
do
	for j in {0..9}
	do
		export TEST_SAMPLE_SEED=$j
		export TEST_SAMPLE_RATIO=0.$i
		PREFIX=0116T$i$TEST_SAMPLE_SEED
		echo $TEST_SAMPLE_RATIO $TEST_SAMPLE_SEED
		if $taint; then # sample for taint
			python3 ../utils/sampletaint.py /tmp/$1/
			unset TEST_SAMPLE_RATIO
			./runbingo.sh $1 /tmp/$1/ taint ${PREFIX}$1 >/dev/null 2>/dev/null
			mv /tmp/$1/dfg/disabled/* /tmp/$1/dfg/
		else
			./runbingo.sh $1 /tmp/$1/ interval ${PREFIX}$1 >/dev/null 2>/dev/null
		fi
	done
done