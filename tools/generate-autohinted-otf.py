import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
	glyph.foreground += glyph.background

font.em = 1000

fontforge.setPrefs ('GenerateHintWidthEqualityTolerance', 4)
fontforge.setPrefs ('StandardSlopeError', 3)
fontforge.setPrefs ('HintBoundingBoxes', 1)
fontforge.setPrefs ('HintDiagonalEnds', 1)
fontforge.setPrefs ('DetectDiagonalStems', 1)
fontforge.setPrefs ('InterpolateStrongPoints', 0)
fontforge.setPrefs ('CounterControl', 1)

font.selection.all ()
font.round ()
font.autoHint ()

font.generate ( destfile, flags=['afm', 'composites-in-afm', 'short-post', 'opentype'] ) #, 'TeX-table'] )
