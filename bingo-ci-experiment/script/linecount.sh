#!/bin/bash

if [[ "$@" =~ "readelf" ]]; then
  for filename in $(ls sparrow/binutils/readelf/*.i | cut -f 2 -d '.' | sed "s/$/.[ch]/g"); do
    wc -l `find . -name $filename` | grep -v "total" | cut -f 1 -d '.'
  done | paste -sd+ | bc
elif [[ "$@" =~ "sort" ]]; then
  for filename in $(ls sparrow/src/sort/*.i | cut -f 2 -d '.' | sed "s/$/.[ch]/g"); do
    wc -l `find . -name $filename` | grep -v "total" | cut -f 1 -d '.'
  done | paste -sd+ | bc
else
  wc -l `find . -name "*.[ch]" ! -path '*gnulib*'`
fi
