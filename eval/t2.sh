echo "Waiting all Bingo runs to finish..."
wait $(pgrep wrapper)
echo "Done!"
python3 ../utils/bingosum.py ''|grep -v 'SAMP'