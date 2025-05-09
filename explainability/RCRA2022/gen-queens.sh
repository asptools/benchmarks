#!/bin/bash

# Generate instances of the n-queens problem
#
# USAGE: gen-queens.sh <number of queens>

source path.sh

NAME=qs

if echo "$1" | egrep '^0$|^[1-9][0-9]*$' > /dev/null
then
  n=$1
else
  echo "USAGE: $0 <number of queens>"
  exit -1
fi

r=$RANDOM

$BIN/gringo -cn=$n $ENC/queens.lp \
| $BIN/clasp --seed=$r --rand-freq=0.1 \
| fgrep 'queen(' | $SCRIPT/asf queen > $TMP/solution-$$.lp

$BIN/gringo --output smodels -cn=$n $ENC/queens.lp \
| $BIN/lpstrip | $BIN/satgrnd | $BIN/lpreify -d \
| sed 's/_int_/_int(/g;s/_int([0-9]*/&)/g' > $TMP/$NAME-neg-n$n-s$r.lp

cp $TMP/$NAME-neg-n$n-s$r.lp $TMP/$NAME-pos-n$n-s$r.lp

$BIN/gringo -cn=$n $TMP/solution-$$.lp select-queen.lp \
| $BIN/clasp --seed=$r --rand-freq=0.1 \
| sed 's/newqueen(/plit(queen(/g;s/noqueen(/nlit(queen(/g;s/)/))/g' \
| fgrep 'lit(' | $SCRIPT/asf plit nlit >> $TMP/$NAME-neg-n$n-s$r.lp

$BIN/gringo -cn=$n -cp=1 $TMP/solution-$$.lp select-queen.lp \
| $BIN/clasp \
| sed 's/newqueen(/plit(queen(/g;s/noqueen(/nlit(queen(/g;s/)/))/g' \
| fgrep 'lit(' | $SCRIPT/asf plit nlit >> $TMP/$NAME-pos-n$n-s$r.lp

mv -f $TMP/$NAME-pos-n$n-s$r.lp $TMP/tmp-$$.lp
$SCRIPT/rmint $TMP/tmp-$$.lp > $TMP/$NAME-pos-n$n-s$r.lp
rm -f $TMP/tmp-$$.lp

mv -f $TMP/$NAME-neg-n$n-s$r.lp $TMP/tmp-$$.lp
$SCRIPT/rmint $TMP/tmp-$$.lp > $TMP/$NAME-neg-n$n-s$r.lp
rm -f $TMP/tmp-$$.lp

rm -f $TMP/solution-$$.lp
