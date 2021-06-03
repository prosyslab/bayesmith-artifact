. env.sh
cd $AHOME
read -d '-' -a shortname <<<"$1"
if [[ " ${BENCHMARKi[@]} " =~ " $1 " ]]; then
	./runbingo.sh $1 /tmp/$1 interval $shortname
else
	./runbingo.sh $1 /tmp/$1 taint $shortname
fi
