#! /usr/bin/bash

gnuplot -p -e "set terminal dumb; set xrange [-1:4]; set yrange [-0.2:1.2]; plot 'generations_plot.txt';"

