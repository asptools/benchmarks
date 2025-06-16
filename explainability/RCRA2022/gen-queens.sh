#!/bin/bash

# Explain-with-Short-Formulas - An Implementation in Answer Set Programming
# Copyright (C) 2025 Tomi Janhunen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Generate instances of the n-queens problem
#
# USAGE: gen-queens.sh <number of queens>

source path.sh

NAME=qs

if echo "$1" | fgrep -E '^0$|^[1-9][0-9]*$' > /dev/null
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

# Generate

mv -f $TMP/$NAME-pos-n$n-s$r.lp $TMP/tmp-$$.lp
$SCRIPT/rmint $TMP/tmp-$$.lp > $TMP/$NAME-pos-n$n-s$r.lp
rm -f $TMP/tmp-$$.lp
echo "Generated $TMP/$NAME-pos-n$n-s$r.lp"

mv -f $TMP/$NAME-neg-n$n-s$r.lp $TMP/tmp-$$.lp
$SCRIPT/rmint $TMP/tmp-$$.lp > $TMP/$NAME-neg-n$n-s$r.lp
rm -f $TMP/tmp-$$.lp
echo "Generated $TMP/$NAME-neg-n$n-s$r.lp"

# Clean-up

rm -f $TMP/solution-$$.lp
