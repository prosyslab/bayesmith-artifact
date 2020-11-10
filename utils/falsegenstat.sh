. env.sh
for x in ${BENCHMARKi[@]};do
echo -e $x
python3 falsegenstat.py $VANILLA_CI/benchmark/$x/sparrow-out/interval/bingo_combined/;
done