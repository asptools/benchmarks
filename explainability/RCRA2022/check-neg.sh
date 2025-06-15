#!/bin/bash

# USAGE: check-neg.sh <negative instance>

source path.sh

$BIN/gringo -Wnone $ENC/check-neg.lp $* | $BIN/clasp | fgrep SAT

# The negative test is passed if clasp returns "UNSATISFIABLE"
