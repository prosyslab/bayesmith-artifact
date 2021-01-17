. env.sh
# ./dupstats.sh | sed 'N;N;s/\n/ /g'
for x in ${BENCHMARKa[@]};do
#wc -l $BINGO/examples/$x/feedbacktrue.txt
echo -e $x
ls /tmp/$x/dfg/*dfg.txt 2>/dev/null |wc -l
ls /tmp/$x/cov/*.praw 2>/dev/null |wc -l
done
for x in ${BENCHMARKi[@]};do
: #wc -l $BINGO_CI/benchmark/$x/sparrow-out/interval/datalog/DUPath.csv
done
for x in ${BENCHMARKt[@]};do
: #wc -l $BINGO_CI/benchmark/$x/sparrow-out/taint/datalog/DUPath.csv
done