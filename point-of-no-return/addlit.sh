#!/bin/bash

# Point of no return: Adding random literal for each arc

file=$1
nat=$2

if ! test -f $file
then
  echo "Arc file $file does not exist!"
  exit -1
fi

if ! test "$nat" -eq "$nat" 2>/dev/null
then
  echo "The second argument '"$nat"' is not a number!"
fi

cat $file \
| while read arc
do
  echo -n "$arc" \
  | sed 's/arc/lit/g;s/)\./,/g'
  a=`echo "scale=0;$RANDOM*$nat/(2^15)" | bc -l`
  if test $RANDOM -gt 16384
  then
    printf "at(%i)" $a
  else
    printf "n(at(%i))" $a
  fi
  echo ")."
done

