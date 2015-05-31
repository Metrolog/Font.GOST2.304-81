import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )

itgFontLib.removeFlippedRefs( font )
itgFontLib.resetGlyphNames( font )
itgFontLib.scaleEM ( font, 1000 )

fontforge.setPrefs ('FoundryName', 'NCSM'); 

fontforge.setPrefs ('AutoHint', 0)

font.selection.all ()
font.round ()

font.generate ( destfile, flags=[ 'afm', 'composites-in-afm', 'short-post', 'opentype', 'TeX-table' ] )
