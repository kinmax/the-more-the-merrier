set datafile separator ','

set terminal pdf

set ylabel "Accuracy" # label for the Y axis
set xlabel 'Number of Samples' # label for the X axis

set yrange [0:110]

set output "./overtime-overall-one.pdf"

set key autotitle columnhead # use the first line as title
plot "overtime-overall-one.csv"  using 1:2 with lines lw 3, '' using 1:3 with lines lw 3, '' using 1:4 with lines lw 3, '' using 1:5 with lines lw 3, '' using 1:6 with lines lw 3