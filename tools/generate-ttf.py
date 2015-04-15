import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
#	if not ( glyph.background.isEmpty() ):
		glyph.layers[1] += glyph.background
		glyph.layers[0] = fontforge.layer()

font.em = 1024

fontforge.setPrefs ('AutoHint', 0)

font.selection.all ()
font.round ()

font.generate ( destfile, flags=['short-post', 'opentype', 'omit-instructions'] ) #, 'TeX-table'] )
