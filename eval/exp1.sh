. ../init.sh
cd $AHOME
read -d '-' -a shortname <<<"$1"
if [[ " ${BENCHMARKi[@]} " =~ " ${name} " ]]; then
	./runbingo.sh $1 /tmp/$1 interval $shortname
else
	./runbingo.sh $1 /tmp/$1 taint $shortname
fi
