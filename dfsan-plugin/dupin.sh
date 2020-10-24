#!/bin/sh
STDIN=$(cat -)
echo $STDIN|./sed2 $@ &
pid=$!
echo $STDIN >$WORKDIR/dfg/$pid.stdin
wait $pid
exit $?
