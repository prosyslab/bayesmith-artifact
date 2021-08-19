#!/usr/bin/env bash

# Usage: ./run.sh [program] [interval | taint] [reuse] [baseline]
# ./run.sh benchmark/optipng-0.5.2.c taint

set -e

########################################################################################################################
# 1. Initialize Options for Various Benchmarks

export PYTHONHASHSEED=0
PGM=$1
ANALYSIS=$2
BASE=`basename $PGM`
BENCHMARK_DIR=`dirname $PGM`
OUTPUT_DIR=$BENCHMARK_DIR/sparrow-out
echo $BASE
OPT_DEFAULT="-unsound_alloc -taint -extract_datalog_fact_full -outdir $OUTPUT_DIR"
if [[ "$BASE" =~ shntool.+ ]]; then 
  OPT=$OPT_DEFAULT
  PGAM=shntool
elif [[ "$BASE" =~ optipng.+ ]]; then
  OPT=$OPT_DEFAULT
  PGAM=optipng
elif [[ "$BASE" =~ urjtag.+ ]]; then
  OPT="$OPT_DEFAULT -unsound_const_string -unsound_skip_file flex -unsound_skip_file bison"
  PGAM=urjtag
elif [[ "$BASE" =~ latex2rtf.+ ]]; then
  OPT="$OPT_DEFAULT -unsound_const_string -unsound_skip_function diagnostics"
  PGAM=latex2rtf
elif [[ "$BASE" =~ wget.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -filter_file hash.c \
    -filter_file html-parse.c -filter_file utils.c -filter_file url.c \
    -filter_allocsite _G_ -filter_allocsite extern
    -filter_allocsite uri_ -filter_allocsite url_ \
    -filter_allocsite fd_read_hunk
    -filter_allocsite main -filter_allocsite gethttp \
    -filter_allocsite strdupdelim -filter_allocsite checking_strdup \
    -filter_allocsite xmemdup \
    -filter_allocsite getftp -filter_allocsite cookie_header \
    -filter_allocsite dot_create"
  PGAM=wget
elif [[ "$BASE" =~ grep.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc"
  PGAM=grep
elif [[ "$BASE" =~ sed.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -filter_allocsite match_regex -filter_file obstack.c \
    -filter_node match_regex-64558 -filter_node do_subst-* \
    -filter_allocsite extern -filter_allocsite _G_ -filter_allocsite quote \
    -filter_function str_append_modified -filter_function compile_regex_1"
  PGAM=sed
elif [[ "$BASE" =~ sort.+  ]]; then
  OPT="$OPT_DEFAULT -inline alloc -unsound_skip_file getdate.y -filter_allocsite yyparse \
    -filter_allocsite extern -filter_allocsite main -filter_allocsite _G_ \
    -filter_file quotearg.c -filter_file printf-args.c -filter_file printf-parse.c"
  PGAM=sort
elif [[ "$BASE" =~ readelf.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -filter_allocsite extern \
    -filter_allocsite _G_ -filter_allocsite simple -filter_allocsite get_"
  PGAM=readelf
elif [[ "$BASE" =~ tar.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -filter_extern -unsound_skip_file parse-datetime \
    -filter_allocsite _G_- -filter_allocsite parse -filter_allocsite delete_archive_members \
    -filter_allocsite hash -filter_allocsite main -filter_allocsite quote \
    -filter_allocsite hol -filter_allocsite header -filter_allocsite xmemdup \
    -filter_allocsite xmalloc -filter_allocsite dump"
  PGAM=tar
elif [[ "$BASE" =~ cflow.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -unsound_alloc -filter_function yy -filter_file c\.l"
  PGAM=cflow
elif [[ "$BASE" =~ bc.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -unsound_alloc"
  PGAM=bc
elif [[ "$BASE" =~ patch.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -unsound_alloc"
  PGAM=patch
elif [[ "$BASE" =~ gzip.+ ]]; then
  OPT="$OPT_DEFAULT -inline alloc -unsound_alloc -unsound_recursion -unsound_noreturn_function"
  PGAM=gzip
else
  OPT=$OPT_DEFAULT
fi

if [[ "$3" = "reuse" ]]; then
  MARSHAL_OPT="-marshal_in"
  MSG=" (reading old results)"
else
  : #MARSHAL_OPT="-marshal_out"
fi

mkdir -p $OUTPUT_DIR/$ANALYSIS/bnet
touch rule-prob.txt

if [[ ! "$@" =~ "--bayesmith" ]]; then
  PGAM=""
fi

########################################################################################################################
# 2. Run Sparrow

START_TIME=$SECONDS
echo "Running Sparrow" $MSG
set -x
sparrow $OPT $MARSHAL_OPT $PGM >& /dev/null
set +x
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Sparrow completes ($ELAPSED_TIME sec)"

########################################################################################################################
# 3. Run Souffle (Deprecated - Run by generator in 4)

#START_TIME=$SECONDS
#echo "Running Souffle"
#if [[ $ANALYSIS == "interval" ]]; then
#  souffle -F $OUTPUT_DIR/interval/datalog -D $OUTPUT_DIR/interval/datalog datalog/BufferOverflow.dl
#else
#  souffle -F $OUTPUT_DIR/taint/datalog -D $OUTPUT_DIR/taint/datalog datalog/IntegerOverflow.dl
#fi
#ELAPSED_TIME=$(($SECONDS - $START_TIME))
#echo "Souffle completes ($ELAPSED_TIME sec)"

########################################################################################################################
# 4. Build Bayesian Network

####
# 4a. Generate named_cons_all.txt

START_TIME=$SECONDS
echo "Building Bayesian Network"
bingo/generator $ANALYSIS $OUTPUT_DIR bnet datalog/ $PGAM >generator.log 2>&1
bingo/generate-alarm.sh $OUTPUT_DIR $ANALYSIS bnet Alarm.csv

####
# 4b. Eliminate cycles, optimize network, build factor graph

bingo/build-bnet.sh $OUTPUT_DIR/$ANALYSIS rule-prob.txt \
  $OUTPUT_DIR/$ANALYSIS/bnet/Alarm.txt bnet
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Building Bayesian Network completes ($ELAPSED_TIME sec)"

########################################################################################################################
# 5. Run Bingo
set -x
if [[ -f "$BENCHMARK_DIR/label.json" ]]; then
  START_TIME=$SECONDS
  echo "Running Bingo"
  # Generate $BENCHMARK_DIR/sparrow-out/datalog/GroundTruth.facts from $BENCHMARK_DIR/label.json
  bingo/generate-ground-truth.py $BENCHMARK_DIR $ANALYSIS bnet
  bingo/accmd $OUTPUT_DIR/$ANALYSIS $OUTPUT_DIR/$ANALYSIS/bnet/Alarm.txt \
    $OUTPUT_DIR/$ANALYSIS/bnet/GroundTruth.txt /dev/null 500 "" /dev/null bnet
  ELAPSED_TIME=$(($SECONDS - $START_TIME))
  echo "Bingo completes ($ELAPSED_TIME sec)"
  script/auc.py $OUTPUT_DIR/$ANALYSIS/bingo_stats.txt $OUTPUT_DIR/$ANALYSIS/bnet/Alarm.txt
else
  NUM_ALARMS=`wc -l $OUTPUT_DIR/$ANALYSIS/bnet/Alarm.txt | cut -f 1 -d ' '`
  echo "Total alarms: $NUM_ALARMS"
fi
