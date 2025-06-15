#!/bin/bash

# USAGE: check-pos.sh <positive instance>

source path.sh

$BIN/gringo -Wnone $ENC/check-pos.lp $* | $BIN/clasp | fgrep SAT

# The positive test is passed if clasp returns "SATISFIABLE"
