. env.sh
cd $AHOME
read -d '-' -a shortname <<<"$1"

if [[ "$@" =~ "--bayesmith" ]]; then
  BAYESMITH_OPT="--bayesmith"
fi

if [[ " ${BENCHMARKi[@]} " =~ " $1 " ]]; then
	./runbingo.sh $1 /tmp/$1 interval $shortname $BAYESMITH_OPT
else
	./runbingo.sh $1 /tmp/$1 taint $shortname $BAYESMITH_OPT
fi
