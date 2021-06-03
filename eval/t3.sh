echo "Waiting all Bingo runs to finish..."
wait $(pgrep wrapper)
echo "Done!"
cd ../utils
./falsegenstat.sh