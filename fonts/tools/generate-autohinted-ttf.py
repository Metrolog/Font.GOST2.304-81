import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[2]
destfile = sys.argv[1]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )

itgFontLib.removeRefsIf( font, itgFontLib.isFlippedOrRotatedRef )
itgFontLib.resetGlyphNames( font )
itgFontLib.scaleEM ( font, 1000 )

fontforge.setPrefs ('FoundryName', 'NCSM'); 
fontforge.setPrefs ('TTFFoundry', 'NCSM') 

fontforge.setPrefs ('GenerateHintWidthEqualityTolerance', 4)
fontforge.setPrefs ('StandardSlopeError', 3)
fontforge.setPrefs ('HintBoundingBoxes', 1)
fontforge.setPrefs ('HintDiagonalEnds', 1)
fontforge.setPrefs ('DetectDiagonalStems', 1)
fontforge.setPrefs ('InstructDiagonalStems', 1)
fontforge.setPrefs ('InstructSerifs', 0)
fontforge.setPrefs ('InstructBallTerminals', 0)
fontforge.setPrefs ('InterpolateStrongPoints', 0)
fontforge.setPrefs ('CounterControl', 0)

font.selection.all ()
font.round ()
font.is_quadratic = True
font.autoHint ()
font.autoInstr ()

font.generate ( destfile, flags=[ 'short-post', 'opentype', 'TeX-table' ] )
