#!/bin/bash

# Generate an instances of the point-of-no-return benchmark
# (c) 2022 Tomi Janhunen
#
# USAGE: mkbench.sh <number of nodes> <number of variables>

DIR=`dirname $0`
TMP=$DIR/tmp
BIN=$DIR/../../asptools-sw/bin # ASPTOOLS binaries in a parallel repository

n=$1
v=$2

# Generate a seed and the respective planar graph

s=$RANDOM
echo "$s" >> $TMP/seeds-$n-$v.txt

$BIN/planar $n $s | fgrep arc > $TMP/$$-graph.lp

# Add random literals to arcs

$DIR/addlit.sh $TMP/$$-graph.lp $v > $TMP/graph-$n-$v-$s.lp

# Ground programs involved

$DIR/ground-all.sh \
  $DIR/ponr-domain.lp $TMP/graph-$n-$v-$s.lp \
  $DIR/ponr-main.lp $DIR/ponr-oracle.lp

# Link programs

$BIN/lpcat ponr-main.sm ponr-oracle.sm > $TMP/graph-$n-$v-$s.sm

# Cleanup

rm -f $TMP/$$-graph.lp
rm -f ponr-main.sm
rm -f ponr-oracle.sm

