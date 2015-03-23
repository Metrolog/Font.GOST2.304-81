import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
	glyph.foreground += glyph.background

font.generate ( destfile ) # , flags=[None] )
