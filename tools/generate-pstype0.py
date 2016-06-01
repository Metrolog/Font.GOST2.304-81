import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[2]
destfile = sys.argv[1]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )

itgFontLib.removeRefsIf( font, itgFontLib.isFlippedRef )
itgFontLib.resetGlyphNames( font )
itgFontLib.scaleEM ( font, 1000 )

fontforge.setPrefs ('FoundryName', 'NCSM'); 

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

font.generate ( destfile, flags = [ 'afm', 'composites-in-afm', 'pfm', 'tfm', 'round' ] )
