. env.sh
for x in ${BENCHMARKi[@]};do
echo -n "$x "
python3 falsegenstat.py $VANILLA_CI/benchmark/$x/sparrow-out/interval/bingo_combined/;
done
for x in ${BENCHMARKt[@]};do
echo -n "$x "
python3 falsegenstat.py $VANILLA_CI/benchmark/$x/sparrow-out/taint/bingo_combined/;
done
echo 'Dynamic'
for x in ${BENCHMARKa[@]};do
echo -n "$x "
read -d '-' -a shortname <<<"$x"
python3 falsegenstat.py $BINGO/$1${shortname}true-combined;
done