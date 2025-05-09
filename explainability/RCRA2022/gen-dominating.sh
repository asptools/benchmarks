#!/bin/bash

# Generate instances of the dominating set problem
#
# USAGE: gen-dominating.sh <number of nodes>

source path.sh

NAME=ds

if echo "$1" | egrep '^0$|^[1-9][0-9]*$' > /dev/null
then
  n=$1
else
  echo "USAGE: $0 <number of nodes>"
  exit -1
fi

r=$RANDOM

$BIN/planar $n $r > $TMP/graph-$$.lp

$BIN/gringo --output smodels -cm=1 $TMP/graph-$$.lp $ENC/dominating.lp \
| $BIN/clasp --opt-strat=usc | fgrep 'in(' | $SCRIPT/asf in > $TMP/optimum-$$.lp

k=`fgrep in $TMP/optimum-$$.lp | wc -l`

$BIN/gringo --output smodels $TMP/graph-$$.lp $ENC/dominating.lp \
| $BIN/lpstrip | $BIN/satgrnd | $BIN/lpreify -d \
| sed 's/_int_/_int(/g;s/_int([0-9]*/&)/g' > $TMP/$NAME-neg-n$n-s$r-k$k.lp

cp $TMP/$NAME-neg-n$n-s$r-k$k.lp $TMP/$NAME-pos-n$n-s$r-k$k.lp

echo "base($n)." \
| $BIN/gringo - $TMP/optimum-$$.lp select-in.lp \
| $BIN/clasp --seed=$r --rand-freq=0.1 \
| sed 's/newin(/plit(in(/g;s/newout(/nlit(in(/g;s/)/))/g' \
| fgrep 'lit(' | $SCRIPT/asf plit nlit >> $TMP/$NAME-neg-n$n-s$r-k$k.lp

echo "base($n)." \
| $BIN/gringo -cp=1 - $TMP/optimum-$$.lp select-in.lp \
| $BIN/clasp --seed=$r --rand-freq=0.1 \
| sed 's/newin(/plit(in(/g;s/newout(/nlit(in(/g;s/)/))/g' \
| fgrep 'lit(' | $SCRIPT/asf plit nlit >> $TMP/$NAME-pos-n$n-s$r-k$k.lp

mv -f $TMP/$NAME-pos-n$n-s$r-k$k.lp $TMP/tmp-$$.lp
$SCRIPT/rmint $TMP/tmp-$$.lp > $TMP/$NAME-pos-n$n-s$r-k$k.lp 
rm -f $TMP/tmp-$$.lp

mv -f $TMP/$NAME-neg-n$n-s$r-k$k.lp $TMP/tmp-$$.lp
$SCRIPT/rmint $TMP/tmp-$$.lp > $TMP/$NAME-neg-n$n-s$r-k$k.lp 
rm -f $TMP/tmp-$$.lp

rm -f $TMP/graph-$$.lp $TMP/optimum-$$.lp
