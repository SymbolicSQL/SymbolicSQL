set term postscript eps color blacktext "Monaco" 16
set output "scale.eps"

set xlabel "Number of symbolic rows"
set ylabel "Execution time (ms)"

set autoscale ymax
set yrange [-3000:*]

set xtics -1, 1, 6
set key center top inside

plot "scale.dat" u 1:2 title 'SimpleRA' with linespoints lw 2.5 ps 1.5, \
     "scale.dat" u 1:3 title 'push-projection' with linespoints lw 2.5 ps 1.5, \
     "scale.dat" u 1:4 title 'subquery-exists' with linespoints lw 2.5 ps 1.5, \
     "scale.dat" u 1:5 title 'magic-set' with linespoints lw 2.5 ps 1.5, \
     "scale.dat" u 1:6 title 'aggr-pull-up' with linespoints lw 2.5 ps 1.5, \
     "scale.dat" u 1:7 title 'subquery-test' with linespoints lw 2.5 ps 1.5, \
     "scale.dat" u 1:8 title 'aggr-join' with linespoints lw 2.5 ps 1.5