. env.sh
for x in ${BENCHMARKa[@]};do
wc -l $BINGO/examples/$x/feedbacktrue.txt
done
for x in ${BENCHMARKi[@]};do
wc -l $BINGO_CI/benchmark/$x/sparrow-out/interval/datalog/DUPath.csv
done
for x in ${BENCHMARKt[@]};do
wc -l $BINGO_CI/benchmark/$x/sparrow-out/taint/datalog/DUPath.csv
done