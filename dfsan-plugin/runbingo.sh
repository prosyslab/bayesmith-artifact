set -e
if [ ! -d "$BINGO" ]; then
	echo 'Not initialized'
	exit 1
fi
APP=$1
WORKDIR=$2/
TYPE=$3 # interval or taint
RUNNAME=$4
if (( $# < 4 )); then
	echo 'wrong usage!'
	exit 1
fi
SUFFIX="true"
if [[ "$@" =~ "--bayesmith" ]]; then
  SUFFIX="bayesmith"
fi
export PYTHONHASHSEED=0
mkdir -p $BINGO/examples/$APP
export PROBLEM_DIR=$BINGO/examples/$APP
pushd $PROBLEM_DIR
rm -rf *
ln -s $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/Alarm.txt base_queries.txt
ln -s $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/GroundTruth.txt oracle_queries.txt
ln -s $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/named_cons_all.txt named_cons_all.txt
touch rule-prob.txt
popd
pushd $BINGO
	pushd $PROBLEM_DIR
		touch observed-tuples.txt
		touch feedback.txt
		cp base_queries.txt observable-tuples.txt
		touch observed-queries.txt
	popd
	./scripts/bnet/build-bnet.sh $PROBLEM_DIR noaugment_base $PROBLEM_DIR/rule-prob.txt
	### @no feedback
	if [ -z "$SKIP_NOFEEDBACK" ]
	then
		echo "AC 1e-6 500 1000 100 ${RUNNAME}nofeedback-stats.txt ${RUNNAME}nofeedback-combined out"| ./scripts/bnet/driver.py $PROBLEM_DIR/bnet/noaugment_base/bnet-dict.out $PROBLEM_DIR/bnet/noaugment_base/factor-graph.fg $PROBLEM_DIR/base_queries.txt $PROBLEM_DIR/oracle_queries.txt >/dev/null 2>&1 &
	fi
popd
# dummy feedbacks for workflow
export INIT=''
touch $WORKDIR/PT.txt
python3 san2fileline.py $WORKDIR init
python3 fileline2feedback.py $WORKDIR $BINGO_CI/benchmark/$APP/sparrow-out/node.json $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/datalog/ /dev/null $PROBLEM_DIR/named_cons_all.txt 2>/dev/null
unset INIT
pushd $PROBLEM_DIR
touch $PROBLEM_DIR/feedback.txt
cp $WORKDIR/observed-queries.txt $PROBLEM_DIR/observed-queries.txt
sed 's/O //' feedback.txt | sed 's/ true//'| sed 's/ false//' | sort | uniq > observed-tuples.txt
grep ', DUPath' named_cons_all.txt | sed 's/.*, DUPath/DUPath/' | sort | uniq > all-dupath.txt
comm -12 all-dupath.txt <(sed 's/O //' feedback.txt | sed 's/ true//'| sed 's/ false//' | sort | uniq) > observed-tuples.txt
cat base_queries.txt observed-tuples.txt > observable-tuples.txt
cd $BINGO
time bash -x  ./scripts/bnet/build-bnet.sh $PROBLEM_DIR noaugment_base $PROBLEM_DIR/rule-prob.txt
echo -e "BP 1e-6 500 1000 100\nPT $WORKDIR/PT.txt"|./scripts/bnet/driver.py $PROBLEM_DIR/bnet/noaugment_base/bnet-dict.out $PROBLEM_DIR/bnet/noaugment_base/factor-graph.fg $PROBLEM_DIR/base_queries.txt $PROBLEM_DIR/oracle_queries.txt >/dev/null
popd
# rankv2
#export RANKV2_PT=$WORKDIR/PT.txt
export RANKV2_PT=$BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bingo_combined/init.out
# generate feedbacks
python3 san2fileline.py $WORKDIR
python3 fileline2feedback.py $WORKDIR $BINGO_CI/benchmark/$APP/sparrow-out/node.json $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/datalog/ $PROBLEM_DIR/bnet/noaugment_base/named_cons_all.txt.pruned.edbobsderived $PROBLEM_DIR/named_cons_all.txt
#python3 fileline2feedback.py $WORKDIR $BINGO_CI/benchmark/$APP/sparrow-out/node.json $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/datalog/ $PROBLEM_DIR/named_cons_all.txt $PROBLEM_DIR/named_cons_all.txt
# done with feedbacks
pushd $PROBLEM_DIR
cp $WORKDIR/feedback.txt $PROBLEM_DIR/feedback.txt
cp $WORKDIR/observed-queries.txt $PROBLEM_DIR/observed-queries.txt
sed 's/O //' feedback.txt | sed 's/ true//'| sed 's/ false//' | sort | uniq > observed-tuples.txt
comm -12 all-dupath.txt <(sed 's/O //' feedback.txt | sed 's/ true//'| sed 's/ false//' | sort | uniq) > observed-tuples.txt
cat base_queries.txt observed-tuples.txt > observable-tuples.txt
ls -l
set +x
for t in $(cut -f 1 observed-queries.txt); do
	echo Obs$t >> observable-tuples.txt
done
set -x

cd ../.. #bingo
time bash -x  ./scripts/bnet/build-bnet.sh $PROBLEM_DIR noaugment_base $PROBLEM_DIR/rule-prob.txt
#./scripts/bnet/elim-inconsistent-fb.py $PROBLEM_DIR/bnet/noaugment_base/named_cons_all.txt.pruned.edbobsderived $PROBLEM_DIR/feedback.txt /dev/null | sponge $PROBLEM_DIR/feedback.txt
echo "AC 1e-6 500 1000 100 ${RUNNAME}full-stats.txt ${RUNNAME}full-combined out" >> $PROBLEM_DIR/feedback.txt
### @full
#cat $PROBLEM_DIR/feedback.txt|./scripts/bnet/driver.py $PROBLEM_DIR/bnet/noaugment_base/bnet-dict.out $PROBLEM_DIR/bnet/noaugment_base/factor-graph.fg $PROBLEM_DIR/base_queries.txt $PROBLEM_DIR/oracle_queries.txt &
grep ' true' $PROBLEM_DIR/feedback.txt > $PROBLEM_DIR/feedbacktrue.txt
echo "AC 1e-6 500 1000 100 ${RUNNAME}${SUFFIX}-stats.txt ${RUNNAME}${SUFFIX}-combined out" >> $PROBLEM_DIR/feedbacktrue.txt
### @true
time ./scripts/bnet/driver.py $PROBLEM_DIR/bnet/noaugment_base/bnet-dict.out $PROBLEM_DIR/bnet/noaugment_base/factor-graph.fg $PROBLEM_DIR/base_queries.txt $PROBLEM_DIR/oracle_queries.txt <$PROBLEM_DIR/feedbacktrue.txt >/dev/null  2>&1 &
### random true baseline
truelines=$(wc -l< $PROBLEM_DIR/feedbacktrue.txt)
popd
python3 randommark.py $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/DUPath.csv $WORKDIR $truelines
pushd $PROBLEM_DIR
cp $WORKDIR/feedback.random $PROBLEM_DIR/feedback.random
cp $WORKDIR/observed-queries.random $PROBLEM_DIR/observed-queries.txt
sed 's/O //' feedback.random | sed 's/ true//'| sed 's/ false//' | sort | uniq > observed-tuples.txt
comm -12 all-dupath.txt <(sed 's/O //' feedback.random | sed 's/ true//'| sed 's/ false//' | sort | uniq) > observed-tuples.txt
cat base_queries.txt observed-tuples.txt > observable-tuples.txt
ls -l
set +x
for t in $(cut -f 1 observed-queries.txt); do
	echo Obs$t >> observable-tuples.txt
done
set -x

cd ../.. #bingo
time bash -x  ./scripts/bnet/build-bnet.sh $PROBLEM_DIR noaugment_base $PROBLEM_DIR/rule-prob.txt
echo "AC 1e-6 500 1000 100 ${RUNNAME}random-stats.txt ${RUNNAME}random-combined out" >> $PROBLEM_DIR/feedback.random
### @random
# cat $PROBLEM_DIR/feedback.random|./scripts/bnet/driver.py $PROBLEM_DIR/bnet/noaugment_base/bnet-dict.out $PROBLEM_DIR/bnet/noaugment_base/factor-graph.fg $PROBLEM_DIR/base_queries.txt $PROBLEM_DIR/oracle_queries.txt >/dev/null 2>&1 &

### @wait
#wait

function waitla {
	target=${1:-$(($(nproc)+4))}
	la=$(cut -d' ' -f 1 /proc/loadavg)
	until [[ $(echo "$la<$target" | bc) -eq "1" ]]; do
		#echo $la
		sleep 1
		la=$(cut -d' ' -f 1 /proc/loadavg)
	done
}
waitla 20