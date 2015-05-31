import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )
itgFontLib.resetGlyphNames( font )
itgFontLib.removeFlippedRefs( font )

font.generate ( destfile ) # , flags=[None] )
