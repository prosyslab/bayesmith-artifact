#!/usr/bin/env bash

set -e

# Usage: ./delta_all.sh [unsound | sound] [eps]

MODE=$1
EPS=$2

echo "shntool"
./delta_single.sh $MODE $EPS shntool &
echo "latex2rtf"
./delta_single.sh $MODE $EPS latex2rtf &
echo "urjtag"
./delta_single.sh $MODE $EPS urjtag &
echo "optipng"
./delta_single.sh $MODE $EPS optipng &
echo "grep"
./delta_single.sh $MODE $EPS grep &
echo "sed"
./delta_single.sh $MODE $EPS sed &
echo "wget"
./delta_single.sh $MODE $EPS wget &
echo "readelf"
./delta_single.sh $MODE $EPS readelf &
echo "sort"
./delta_single.sh $MODE $EPS sort &
echo "tar"
./delta_single.sh $MODE $EPS tar &
wait
