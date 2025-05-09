#!/bin/bash

# USAGE: run-pos.sh <positive instance>

source path.sh

# Optimize

$BIN/gringo -Wnone $ENC/minimize.lp $ENC/oracle-pos.lp $* \
| $BIN/clasp --opt-strat=usc
