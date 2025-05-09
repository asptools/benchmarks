#!/bin/bash

# USAGE: run-pos.sh <positive instance>

source path.sh

OPT=usc

if test "$1" = "-bb"
then
  OPT=bb
  shift
fi

# Ground the main program and translate the oracle program

$BIN/gringo -Wnone --output smodels -Wnone $ENC/minimize.lp $* \
| $BIN/lpstrip  > $TMP/main-$$.sm

$BIN/gringo -Wnone --output smodels $ENC/oracle-neg.lp $* \
| $BIN/lpstrip | $BIN/lpcat | $BIN/lp2normal2 | $BIN/lp2acyc \
| $BIN/lp2sat | $BIN/unsat2lp > $TMP/oracle-$$.sm

# Link the oracle with the main program and optimize

$BIN/lpcat $TMP/main-$$.sm $TMP/oracle-$$.sm \
| $BIN/clasp --opt-strat=$OPT

rm -f $TMP/main-$$.sm
rm -f $TMP/oracle-$$.sm
