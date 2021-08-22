#!/usr/bin/env bash

if [[ "$@" =~ "--bayesmith" ]]; then
  BAYESMITH_OPT="--bayesmith"
fi

./runbingo.sh bc-1.06 /tmp/bc-1.06/ interval ${PREFIX}bc $BAYESMITH_OPT >/dev/null 2>/dev/null &
./runbingo.sh cflow-1.5 /tmp/cflow-1.5/ interval ${PREFIX}cflow $BAYESMITH_OPT >/dev/null 2>/dev/null &
./runbingo.sh grep-2.19 /tmp/grep-2.19/ interval ${PREFIX}grep $BAYESMITH_OPT > /dev/null 2> /dev/null &
./runbingo.sh gzip-1.2.4a /tmp/gzip-1.2.4a/ interval ${PREFIX}gzip $BAYESMITH_OPT > /dev/null 2> /dev/null &
./runbingo.sh patch-2.7.1 /tmp/patch-2.7.1/ interval ${PREFIX}patch $BAYESMITH_OPT > /dev/null 2> /dev/null &
./runbingo.sh readelf-2.24 /tmp/readelf-2.24/ interval ${PREFIX}readelf $BAYESMITH_OPT >/dev/null 2>/dev/null &
./runbingo.sh sed-4.3 /tmp/sed-4.3/ interval ${PREFIX}sed $BAYESMITH_OPT >/dev/null 2>/dev/null &
./runbingo.sh sort-7.2 /tmp/sort-7.2/ interval ${PREFIX}sort $BAYESMITH_OPT > /dev/null 2> /dev/null &
./runbingo.sh tar-1.28 /tmp/tar-1.28/ interval ${PREFIX}tar $BAYESMITH_OPT > /dev/null 2> /dev/null &
./runbingo.sh optipng-0.5.3 /tmp/optipng-0.5.3/ taint ${PREFIX}optipng $BAYESMITH_OPT >/dev/null 2>/dev/null &
./runbingo.sh latex2rtf-2.1.1 /tmp/latex2rtf-2.1.1/ taint ${PREFIX}latex2rtf $BAYESMITH_OPT >/dev/null 2>/dev/null &
./runbingo.sh shntool-3.0.5 /tmp/shntool-3.0.5/ taint ${PREFIX}shntool $BAYESMITH_OPT >/dev/null 2>/dev/null &
