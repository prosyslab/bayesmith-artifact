#$1 app name
#$2 type
#example: sort-7.2
python3 ../utils/gensamplecov.py $1 /tmp/$1/ $2 > /tmp/$1/covexp.sh
. /tmp/$1/covexp.sh