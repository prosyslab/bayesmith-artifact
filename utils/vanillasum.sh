. env.sh
for x in ${BENCHMARKi[@]};do
echo -n "$x "
python3 vanillasum.py $VANILLA_CI/benchmark/$x/sparrow-out/interval/bingo_combined/;
done
for x in ${BENCHMARKt[@]};do
echo -n "$x "
python3 vanillasum.py $VANILLA_CI/benchmark/$x/sparrow-out/taint/bingo_combined/;
done