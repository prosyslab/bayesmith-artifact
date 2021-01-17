mkdir -p /tmp/sampleplots
app=readelf
python3 utils/bingosum.py 0110|grep $app | awk -F, '{ print $5; }'|python3 utils/sampleplot.py $app