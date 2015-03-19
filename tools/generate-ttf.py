import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

font.em = 1024

fontforge.setPrefs ('AutoHint', 0)

font.selection.all ()
font.round ()

font.generate (destfile)
