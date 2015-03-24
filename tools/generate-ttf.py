import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
	glyph.foreground += glyph.background

font.em = 1024

fontforge.setPrefs ('AutoHint', 0)

font.selection.all ()
font.round ()

font.generate ( destfile, flags=['short-post', 'apple', 'opentype', 'old-kern', 'omit-instructions'] ) #, 'TeX-table'] )
