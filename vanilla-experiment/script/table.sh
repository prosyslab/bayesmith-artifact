#!/bin/bash

OLD_VERSION=( "shntool-3.0.4.taint" "latex2rtf-2.1.0.taint" "urjtag-0.7.taint" "optipng-0.5.2.taint" "wget-1.11.4.interval" \
  "readelf-2.23.2.interval" "grep-2.18.interval" "sed-4.2.2.interval" "sort-7.1.interval" "tar-1.27.interval" )
NEW_VERSION=( "shntool-3.0.5.taint" "latex2rtf-2.1.1.taint" "urjtag-0.8.taint" "optipng-0.5.3.taint" "wget-1.12.interval" \
  "readelf-2.24.interval" "grep-2.19.interval" "sed-4.3.interval" "sort-7.2.interval" "tar-1.28.interval" )

echo ""
echo "Batch mode OLD alarms"
printf "%-25s: %7s \n" "Program" "Alarms"
total=0
for p in "${OLD_VERSION[@]}"; do
  ALARMS=`grep -i "Total alarms" result/$p.batch.log | cut -d ':' -f 2`
  printf "%-25s: %7s\n" "$p" "$ALARMS"
  total=$(($total+$ALARMS))
done
printf "%-25s: %7s\n" "Total" "$total"

echo ""
echo "Batch mode NEW alarms"
total_alarms=0
total_iters=0
total_bugs=0
printf "%-25s: %7s | %5s | %5s | %5s\n" "Program" "Alarms" "Iters" "Bugs" "AUC"
for p in "${NEW_VERSION[@]}"; do
  ALARMS=`grep -i "Total alarms" result/$p.batch.log | cut -d ':' -f 2`
  ITERS=`grep -i "Last true" result/$p.batch.log | cut -d ':' -f 2`
  BUGS=`grep -i "True alarms" result/$p.batch.log | cut -d ':' -f 2`
  AUC=`grep -i "AUC" result/$p.batch.log | cut -d ':' -f 2`
  printf "%-25s: %7s | %5s | %5s | %5s\n" "$p" "$ALARMS" "$ITERS" "$BUGS" "$AUC"
  total_alarms=$(($total_alarms+$ALARMS))
  total_iters=$(($total_iters+$ITERS))
  total_bugs=$(($total_bugs+$BUGS))
done
printf "%-25s: %7s | %5s | %5s\n" "Total" "$total_alarms" "$total_iters" "$total_bugs"

FB_MODE=( "strong" "weak" )
for fb in "${FB_MODE[@]}"; do
  echo ""
  echo "CI mode with Syntactic $fb Masking"
  total_alarms=0
  total_iters=0
  total_bugs=0
  printf "%-25s: %7s | %5s | %5s\n" "Program" "Alarms" "Iters" "Bugs"
  for p in "${NEW_VERSION[@]}"; do
    ALARMS=`grep -i "Total alarms" result/$p.delta.syn.$fb.log | cut -d ':' -f 2`
    ITERS=`grep -i "Last true" result/$p.delta.syn.$fb.log | cut -d ':' -f 2`
    BUGS=`grep -i "True alarms" result/$p.delta.syn.$fb.log | cut -d ':' -f 2`
    printf "%-25s: %7s | %5s | %5s\n" "$p" "$ALARMS" "$ITERS" "$BUGS"
    total_alarms=$(($total_alarms+$ALARMS))
    total_iters=$(($total_iters+$ITERS))
    total_bugs=$(($total_bugs+$BUGS))
  done
  printf "%-25s: %7s | %5s | %5s\n" "Total" "$total_alarms" "$total_iters" "$total_bugs"
done

MODE=( "sem" "sem-eps" )
FB_MODE=( "strong" "inter" "weak" )
for mode in "${MODE[@]}"; do
  for fb in "${FB_MODE[@]}"; do
    echo ""
    echo "CI mode with Semantic ($mode) $fb Masking"
    total_alarms=0
    total_iters=0
    total_bugs=0
    printf "%-25s: %7s | %5s | %5s\n" "Program" "Alarms" "Iters" "Bugs"
    for p in "${NEW_VERSION[@]}"; do
      ALARMS=`grep -i "Total alarms" result/$p.delta.$mode.$fb.log | cut -d ':' -f 2`
      ITERS=`grep -i "Last true" result/$p.delta.$mode.$fb.log | cut -d ':' -f 2`
      BUGS=`grep -i "True alarms" result/$p.delta.$mode.$fb.log | cut -d ':' -f 2`
      printf "%-25s: %7s | %5s | %5s\n" "$p" "$ALARMS" "$ITERS" "$BUGS"
      total_alarms=$(($total_alarms+$ALARMS))
      total_iters=$(($total_iters+$ITERS))
      total_bugs=$(($total_bugss+$BUGS))
    done
    printf "%-25s: %7s | %5s | %5s\n" "Total" "$total_alarms" "$total_iters" "$total_bugss"
  done
done

FB_MODE=( "0.001" "0.005" "0.01" "0.05" "0.1" "0.5" )
for eps in "${FB_MODE[@]}"; do
  echo ""
  echo "CI mode with Semantic (eps = $eps) $fb Masking"
  mode="sem-eps"
  fb="strong"
  total_alarms=0
  total_iters=0
  total_bugs=0
  printf "%-25s: %7s | %5s | %5s\n" "Program" "Alarms" "Iters" "Bugs"
  for p in "${NEW_VERSION[@]}"; do
    ALARMS=`grep -i "Total alarms" result/$p.delta.$mode.$fb.$eps.log | cut -d ':' -f 2`
    ITERS=`grep -i "Last true" result/$p.delta.$mode.$fb.$eps.log | cut -d ':' -f 2`
    BUGS=`grep -i "True alarms" result/$p.delta.$mode.$fb.$eps.log | cut -d ':' -f 2`
    printf "%-25s: %7s | %5s | %5s\n" "$p" "$ALARMS" "$ITERS" "$BUGS"
    total_alarms=$(($total_alarms+$ALARMS))
    total_iters=$(($total_iters+$ITERS))
    total_bugs=$(($total_bugss+$BUGS))
  done
  printf "%-25s: %7s | %5s | %5s\n" "Total" "$total_alarms" "$total_iters" "$total_bugss"
done
