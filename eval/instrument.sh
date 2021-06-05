. env.sh
cd $AHOME
if [[ " ${BENCHMARKi[@]} " =~ " $1 " ]]; then
	echo ''|./go.sh $1 $1 1 0
else
	for i in {0..19};do echo ''|./go.sh $1 $1 20 $i;done
fi