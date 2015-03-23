import fontforge
import sys

destfile = sys.argv[1]
ttfFonts = [ fontforge.open (sys.argv[i]) for i in range(2, len(sys.argv)) ]
font = ttfFonts.pop ()

font.generateTtc (destfile,	ttfFonts, layer=1, ttcflags = [None], flags = ['TeX-table', None])
