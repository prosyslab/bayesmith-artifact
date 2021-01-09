. env.sh
pushd ../dfsan-plugin
for x in ${BENCHMARKa[@]};do
echo $x
./go-asan.sh $x asanws 1 0 2>&1 |grep "#2 0x" |grep 'in' |sort |uniq -c
./go-asan.sh $x asanws 1 0 2>&1 |grep "#2 0x" |grep 'in' |sort |uniq -c
find /tmp/asanws -type f |xargs grep "#2 0x" |grep 'in'|sort |uniq -c
rm -rf /tmp/asanws
done