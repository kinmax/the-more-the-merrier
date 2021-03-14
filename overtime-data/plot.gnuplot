set datafile separator ','

set ylabel "Accuracy" # label for the Y axis
set xlabel 'Number of Samples' # label for the X axis

set output "./overtime-logistics-one.pdf"

set key autotitle columnhead # use the first line as title
plot "overtime-logistics-one.csv"  using 1:2 with lines lw 2, '' using 1:3 with lines lw 2, '' using 1:4 with lines lw 2, '' using 1:5 with lines lw 2, '' using 1:6 with lines lw 2