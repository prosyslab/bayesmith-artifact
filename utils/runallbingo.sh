PREFIX=0829
./runbingo.sh bc-1.06 /tmp/bc-1.06/ interval ${PREFIX}bc >/dev/null 2>/dev/null &
./runbingo.sh cflow-1.5 /tmp/cflow-1.5/ interval ${PREFIX}cflow >/dev/null 2>/dev/null &
./runbingo.sh grep-2.19 /tmp/grep-2.19/ interval ${PREFIX}grep > /dev/null 2> /dev/null &
./runbingo.sh gzip-1.2.4a /tmp/gzip-1.2.4a/ interval ${PREFIX}gzip > /dev/null 2> /dev/null &
./runbingo.sh libtasn1-4.3 /tmp/libtasn1-4.3/ interval ${PREFIX}libtasn1 > /dev/null 2> /dev/null &
./runbingo.sh patch-2.7.1 /tmp/patch-2.7.1/ interval ${PREFIX}patch > /dev/null 2> /dev/null &
./runbingo.sh readelf-2.24 /tmp/readelf-2.24/ interval ${PREFIX}readelf >/dev/null 2>/dev/null &
./runbingo.sh sed-4.3 /tmp/sed-4.3/ interval ${PREFIX}sed >/dev/null 2>/dev/null &
./runbingo.sh sort-7.2 /tmp/sort-7.2/ interval ${PREFIX}sort > /dev/null 2> /dev/null &
./runbingo.sh tar-1.28 /tmp/tar-1.28/ interval ${PREFIX}tar > /dev/null 2> /dev/null &
