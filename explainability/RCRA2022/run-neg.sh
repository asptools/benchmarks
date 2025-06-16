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
