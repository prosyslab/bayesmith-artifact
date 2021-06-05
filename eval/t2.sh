if pgrep wrapper; then
echo "WARNING: Bingo run is not finished, the below results are not final."
fi
python3 ../utils/bingosum.py ''|grep -v 'SAMP'