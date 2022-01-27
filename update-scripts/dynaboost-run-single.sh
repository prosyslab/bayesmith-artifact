cd $AHOME

PROG=$1

if [[ "$@" =~ "--bayesmith" ]]; then
  BAYESMITH_OPT="--bayesmith"
fi

../utils/runsinglebingo.sh $PROG $BAYESMITH_OPT