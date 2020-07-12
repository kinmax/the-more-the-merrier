#!/bin/bash 
reset

gnuplot -persist <<-EOFMarker

    set terminal pdf font "Helvetica,8" enhanced

    set xlabel "Observability" font ", 14"
    set ylabel "Accuracy/Spread" font ", 14"

    set ytics font ", 14"
    set xtics font ", 14"

    set key font ",14"
    set key top left

    set out "bar_graph_goal_goalcompletion_noisy_zero.pdf"

    set yrange [0:100]
    set style data histogram
    set style histogram cluster gap 1
    set style fill solid
    set boxwidth 0.9
    set xtics format ""
    set grid ytics

    # plot "bar_graph.txt" using 2:xtic(1) title "Exhaust" linecolor "red", \
    #             '' using 3 title "h^m" linecolor "blue", \
    #             '' using 4 title "RHW" linecolor "green", \
    #             '' using 5 title "Zhu/Givan" linecolor "orange", \
    #             '' using 6 title "Hoffmann" linecolor "dark-grey"

    plot "bar_graph_noisy.txt" using 2:xtic(1) title "Exhaust" linecolor "dark-red" fs solid 0.5, \
                '' using 3 title "h^m" linecolor "dark-blue" fs solid 0.5, \
                '' using 4 title "RHW" linecolor "dark-green" fs solid 0.5, \
                '' using 5 title "Zhu/Givan" linecolor "dark-orange" fs solid 0.5, \
                '' using 6 title "Hoffmann" linecolor "#424242" fs solid 0.5

    # plot "bar_graph.txt" using 2:xtic(1) title "Exhaust" linecolor "red" fs pattern 2, \
    #             '' using 3 title "h^m" linecolor "blue" fs pattern 2, \
    #             '' using 4 title "RHW" linecolor "green" fs pattern 2, \
    #             '' using 5 title "Zhu/Givan" linecolor "orange" fs pattern 2, \
    #             '' using 6 title "Hoffmann" linecolor "dark-grey" fs pattern 2
EOFMarker