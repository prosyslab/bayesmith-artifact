cd $AHOME

if [[ "$@" =~ "--bayesmith" ]]; then
  BAYESMITH_OPT="--bayesmith"
fi

../utils/runallbingo.sh $BAYESMITH_OPT
