mkdir -p /tmp/sampleplots
. env.sh
for app in ${BENCHMARKa[@]};do
echo -n "$x "
python3 bingosum.py SAMP|grep $app | awk -F, '{ print $5; }'|python3 sampleplot.py $app
done