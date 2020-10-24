#$1 app name
#$2 short name
for i in {1..9}
do
	for j in {0..9}
	do
		export FEEDBACK_SAMPLE_SEED=$((i*10+j))
		export FEEDBACK_SAMPLE_RATIO=0.$i
		PREFIX=1022T$FEEDBACK_SAMPLE_SEED
		echo $FEEDBACK_SAMPLE_RATIO $FEEDBACK_SAMPLE_SEED
		./runbingo.sh $1 /tmp/$1/ interval ${PREFIX}$2 >/dev/null 2>/dev/null
	done
done