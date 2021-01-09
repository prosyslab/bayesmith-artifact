driver=./go.sh
$driver tar-1.28 tar-1.28 1 0
$driver sort-7.2 sort-7.2 1 0
$driver readelf-2.24 readelf-2.24 1 0;$driver readelf-2.24 readelf-2.24 1 0 # needs twice
$driver grep-2.19 grep-2.19 1 0
$driver sed-4.3 sed-4.3 1 0
$driver bc-1.06 bc-1.06 1 0
$driver libtasn1-4.3 libtasn1-4.3 1 0
$driver cflow-1.5 cflow-1.5 1 0
$driver patch-2.7.1 patch-2.7.1 1 0
$driver gzip-1.2.4a gzip-1.2.4a 1 0
for i in {0..19};do $driver optipng-0.5.3 optipng-0.5.3 20 $i;done
for i in {0..19};do $driver shntool-3.0.5 shntool-3.0.5 20 $i;done
for i in {0..19};do $driver latex2rtf-2.1.1 latex2rtf-2.1.1 20 $i;done