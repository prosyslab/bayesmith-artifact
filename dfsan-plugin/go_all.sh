driver=${1:-./go.sh}
prefix=$2
$driver tar-1.28 ${prefix}tar-1.28 1 0 &
$driver sort-7.2 ${prefix}sort-7.2 1 0 &
$driver readelf-2.24 ${prefix}readelf-2.24 1 0;$driver readelf-2.24 ${prefix}readelf-2.24 1 0 &# needs twice
$driver grep-2.19 ${prefix}grep-2.19 1 0 &
$driver sed-4.3 ${prefix}sed-4.3 1 0 &
$driver bc-1.06 ${prefix}bc-1.06 1 0 &
$driver cflow-1.5 ${prefix}cflow-1.5 1 0 &
$driver patch-2.7.1 ${prefix}patch-2.7.1 1 0 &
$driver gzip-1.2.4a ${prefix}gzip-1.2.4a 1 0 &
for i in {0..19};do $driver optipng-0.5.3 ${prefix}optipng-0.5.3 20 $i;done
for i in {0..19};do $driver shntool-3.0.5 ${prefix}shntool-3.0.5 20 $i;done
for i in {0..19};do $driver latex2rtf-2.1.1 ${prefix}latex2rtf-2.1.1 20 $i;done