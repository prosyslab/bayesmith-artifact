#$1 app name
#example: sort-7.2
#sudo chmod -R 777 /tmp/$1
for i in {1..9}
do
	for j in {0..9}
	do
		export TEST_SAMPLE_SEED=$j
		export TEST_SAMPLE_RATIO=0.$i
		PREFIX=0116T$i$TEST_SAMPLE_SEED
		echo $TEST_SAMPLE_RATIO $TEST_SAMPLE_SEED
		./runbingo.sh $1 /tmp/$1/ interval ${PREFIX}$1 >/dev/null 2>/dev/null
	done
done