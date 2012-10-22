#!/bin/sh

# Inspired by
# http://jperalta.wordpress.com/2007/05/04/fast-plot-from-bash

# Take just the first column from the stats file -Jared 2012-10-21
TMP_DATA="/tmp/git_stats.dat"
rm $TMP_DATA 2> /dev/null
awk '{print $1}' "$1" > $TMP_DATA

# Build a gnuplot script -Jared 2012-10-21
TMP_SCRIPT="/tmp/git_stats_plot.tmp"
rm $TMP_SCRIPT 2> /dev/null
echo 'set title "Lines of Code Over Project History"' >> $TMP_SCRIPT
echo 'set xlabel "commits"' >> $TMP_SCRIPT
echo 'set ylabel "lines of code"' >> $TMP_SCRIPT
echo "plot \"$TMP_DATA\" " >> $TMP_SCRIPT
echo "" >> $TMP_SCRIPT
gnuplot -persist $TMP_SCRIPT
