#!/bin/bash

# Stable-unstable semantics: ground the main program and any oracles

DIR=`dirname $0`
BIN=$DIR/../../asptools-sw/bin # ASPTOOLS binaries in parallel repository

DOM=$1

if ! test -f $DOM
then
  echo "Domain file $DOM does not exist!"
  exit -1
fi

INST=$2

if ! test -f $INST
then
  echo "Instance file $INST does not exist!"
  exit -1
fi

MAIN=$3

if ! test -f $MAIN
then
  echo "Main program $MAIN does not exist!"
  exit -1
fi

name=`basename $MAIN .lp`

echo "Grounding the main program:"

$BIN/gringo --output smodels $DOM $INST $MAIN > $name.sm
echo -n " - $name.sm ("
len -a $name.sm | tr -d "\n"
echo -n " atoms, "
len -r $name.sm | tr -d "\n"
echo " rules)"

shift 3

echo "Grounding and translating oracles (if any):"

for o in $*
do
  if ! test -f $o
  then
    echo "Oracle program $o does not exist!"
    exit -1
  fi
  name=`basename $o .lp`

  $BIN/gringo --output smodels $DOM $INST $o \
  | $BIN/lpstrip | $BIN/lpcat | $BIN/lp2normal2 \
  | $BIN/lp2acyc | $BIN/lp2sat -b | $BIN/unsat2lp > $name.sm
  echo -n " - $name.sm ("
  len -a $name.sm | tr -d "\n"
  echo -n " atoms, "
  len -r $name.sm | tr -d "\n"
  echo " rules)"
done
