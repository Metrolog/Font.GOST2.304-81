import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

font.em = 1024

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

font.generate (destfile)
