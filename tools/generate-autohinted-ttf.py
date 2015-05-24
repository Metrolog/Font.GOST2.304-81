import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )

itgFontLib.removeFlippedRefs( font )

xheight = font.os2_xheight
capheight = font.os2_capheight
scale = 1024 / font.em
font.em = 1024
font.os2_xheight = xheight * scale
font.os2_capheight = capheight * scale

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

font.generate ( destfile, flags=['short-post', 'opentype', 'TeX-table'] )
