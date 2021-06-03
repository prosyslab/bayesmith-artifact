. env.sh
cd $AHOME
if [[ " ${BENCHMARKi[@]} " =~ " ${name} " ]]; then
	./go.sh $1 $1 1 0
else
	for i in {0..19};do ./go.sh $1 $1 20 $i;done
fi