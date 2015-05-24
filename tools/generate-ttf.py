import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )
itgFontLib.resetGlyphNames( font )
itgFontLib.removeFlippedRefs( font )

itgFontLib.scaleEM ( font, 1024 )

fontforge.setPrefs ('FoundryName', 'NCSM'); 
fontforge.setPrefs ('TTFFoundry', 'NCSM') 

fontforge.setPrefs ('AutoHint', 0)

font.selection.all ()
font.round ()

font.generate ( destfile, flags=[ 'short-post', 'opentype', 'omit-instructions', 'TeX-table' ] )
