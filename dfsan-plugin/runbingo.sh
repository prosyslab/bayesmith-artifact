BINGO=$PWD/../../bingo/
#set -e
BINGO_CI=$PWD/../../bingo-ci-experiment/
APP=$1
WORKDIR=$2/
TYPE=$3 # interval or taint
if (( $# < 3 )); then
	echo 'wrong usage!'
	exit 1
fi
export PYTHONHASHSEED=0
mkdir -p $BINGO/examples/$APP
pushd $BINGO/examples/$APP
export PROBLEM_DIR=$BINGO/examples/$APP
rm -rf *
cp $WORKDIR/feedback.txt $BINGO/examples/$APP/feedback.txt
cp $WORKDIR/observed-queries.txt $BINGO/examples/$APP/observed-queries.txt
ln -s $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/Alarm.txt base_queries.txt
ln -s $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/GroundTruth.txt oracle_queries.txt
ln -s $BINGO_CI/benchmark/$APP/sparrow-out/$TYPE/bnet/named_cons_all.txt named_cons_all.txt
touch rule-prob.txt
grep ', DUPath' named_cons_all.txt | sed 's/.*, DUPath/DUPath/' | sort | uniq > all-dupath.txt
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
time bash -x  ./scripts/bnet/build-bnet.sh $PROBLEM_DIR noaugment_base $PROBLEM_DIR/rule-prob.txt||echo 'failed'
echo "AC 1e-6 500 1000 100 stats.txt combined out" >> $PROBLEM_DIR/feedback.txt
./scripts/bnet/driver.py $PROBLEM_DIR/bnet/noaugment_base/bnet-dict.out $PROBLEM_DIR/bnet/noaugment_base/factor-graph.fg $PROBLEM_DIR/base_queries.txt $PROBLEM_DIR/oracle_queries.txt <$PROBLEM_DIR/feedback.txt

