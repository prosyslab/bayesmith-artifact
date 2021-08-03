#!/usr/bin/env bash

# Runs Delta Bingo in the specified mode (either syn or sem) and feedback setting (strong, inter, or
# weak)
# Usage: ./delta.sh OLD_PROGRAM_DIR NEW_PROGRAM_DIR [interval | taint] [syn | sem] [strong | inter | weak]

set -e

if [[ $# -lt 4 ]]; then
  echo "Invalid Argument"
  exit 1
fi

OLD_PGM=$1
NEW_PGM=$2
ANALYSIS=$3
MODE=$4
FB_MODE=$5
EPS=$6

# NOTE: This command produces large amounts of logging data on stderr, and so stderr is only redirected to the logging
# file.
if [[ "$@" =~ "reuse-trans" ]]; then
  echo "Reusing old translation" 1>&2
else
  OLD_OUTPUT_DIR=$OLD_PGM/sparrow-out
  NEW_OUTPUT_DIR=$NEW_PGM/sparrow-out
  bingo/translate-cons.py $OLD_OUTPUT_DIR/$ANALYSIS/bnet/named_cons_all.txt \
                          $NEW_OUTPUT_DIR/$ANALYSIS/bnet/named_cons_all.txt \
                          $OLD_OUTPUT_DIR/$ANALYSIS/bnet/Alarm.txt \
                          $NEW_OUTPUT_DIR/$ANALYSIS/bnet/Alarm.txt \
                          $OLD_OUTPUT_DIR/node.json \
                          $NEW_OUTPUT_DIR/node.json \
                          $NEW_PGM/line_matching.json \
                          $NEW_OUTPUT_DIR/$ANALYSIS/bnet \
                          2> $NEW_OUTPUT_DIR/$ANALYSIS/bnet/translate-cons.err
fi

if [[ "$@" =~ "reuse-bnet" ]]; then
  REUSE=reuse
fi

if [[ "$MODE" == "syn" ]]; then
  ./delta/syn.sh $OLD_PGM $NEW_PGM $ANALYSIS $FB_MODE
elif [[ "$MODE" == "sem" ]]; then
  ./delta/sem.sh $OLD_PGM $NEW_PGM $ANALYSIS $FB_MODE $REUSE
elif [[ "$MODE" == "sem-eps" ]]; then
  ./delta/sem-eps.sh $OLD_PGM $NEW_PGM $ANALYSIS $FB_MODE $EPS $REUSE
else
  echo "Invalid Argument"
  exit 1
fi
