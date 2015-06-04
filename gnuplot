# .gnuplotrc

### Note: use the command "test" to see thes colours in action

# set terminal and a less bright background
MistyRose  = '#ffe4e1'
MistyRose2 = '#eed5d2'
MistyRose3 = '#cdb7b5'
MistyRose4 = '#8b7d7b'
#
LavenderBlush  = '#fff0f5'
Lavender       = '#e6e6fa'
LavenderBlush2 = '#eee0e5'
LavenderBlush3 = '#cdc1c5'
LavenderBlush4 = '#8b8386'
#
set term x11 size 1300,900 raise persist ctrlq background rgb MistyRose2

# grid lines
set grid nomxtics xtics
set grid nomx2tics nox2tics
set grid nomytics ytics
set grid nomy2tics noy2tics

# turn off tic mirrors
set xtics nomirror
set x2tics nomirror
set ytics nomirror
set y2tics nomirror

# line colours
set linetype 1  lc rgb 'forest-green' lw 2 pt 2
set linetype 2  lc rgb 'olive'        lw 2 pt 7
set linetype 3  lc rgb 'cyan'         lw 2 pt 6
set linetype 4  lc rgb 'red'          lw 2 pt 5
set linetype 5  lc rgb 'blue'         lw 2 pt 8
set linetype 6  lc rgb 'goldenrod'    lw 2 pt 3
set linetype 7  lc rgb 'black'        lw 2 pt 11
set linetype 8  lc rgb 'magenta'      lw 2
set linetype 9  lc rgb 'coral'        lw 2
set linetype 10 lc rgb 'plum'         lw 2
set linetype cycle 10

# macros
set macros

# set selected items
#
# command:  gnuplot -e 'item="simple complex"' graphs.plt
#
# if not set on command line, i.e. gnuplot graphs.plt
if (!exists('item')) {
  item = '*'
}

# ensure emacs false is set to a default value
if (!exists('emacs')) {
  emacs = 0
}

# delay between graphs if more than one are selected
#PAUSE="if ('*' eq item || words(item) > 1) {pause 10 'waiting 10 seconds…';}"
PAUSE="\
if ('*' eq item || words(item) > 1 || emacs) {\
pause mouse any 'press mouse button or Enter to continue, Q or X to exit…';\
print '';\
set terminal x11 close;\
if ('Q' eq MOUSE_CHAR || 'q' eq MOUSE_CHAR || 'X' eq MOUSE_CHAR || 'x' eq MOUSE_CHAR) { unset output; print 'EXIT'; exit gnuplot; };\
};"

# see if particular plot is selected
doplot(x) = 0 != strstrt(item, x) || '*' eq item


# example graph using @PAUSE: simple
#
# plots if 'simple" is specified or nothing (default: '*')
#
# if (doplot('simple')) {
#     set title 'Simple graph'
#     plot [start:finish] \
#          'simple.data' using ($1):($2) with lines title columnheader(2) axes x1y2, \
#          'simple.data' using ($1):($3) with lines title columnheader(3), \
#          'simple.data' using ($1):($4) with lines title columnheader(4)
#
#     @PAUSE
# }
