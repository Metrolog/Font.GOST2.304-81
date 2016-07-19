import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[2]
destfile = sys.argv[1]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )
itgFontLib.resetGlyphNames( font )
itgFontLib.removeRefsIf( font, itgFontLib.isFlippedOrRotatedRef )

font.generate ( destfile ) # , flags=[None] )
