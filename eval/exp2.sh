. ../init.sh
cd $UHOME
# benchmark, [interval/taint]
if [[ " ${BENCHMARKi[@]} " =~ " ${name} " ]]; then
	./runsample10.sh $1 interval
else
	./runsample10.sh $1 taint
fi
