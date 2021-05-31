. env.sh
#0121
#0211bc
# mkdir -p $2
# python3 plot.py $BINGO/$1 $2 interval ${BENCHMARKi[@]}
# python3 plot.py $BINGO/$1 $2 taint ${BENCHMARKt[@]}
mkdir -p $1
echo ${BENCHMARKi[@]}
python3 plot.py $BINGO $1 interval ${BENCHMARKi[@]}
python3 plot.py $BINGO $1 taint ${BENCHMARKt[@]}
