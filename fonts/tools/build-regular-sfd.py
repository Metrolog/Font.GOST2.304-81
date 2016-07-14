#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge
import sys
import itgFontLib

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)
itgFontLib.fontPreProcessing( font )

font.macstyle = 0

font.save (destfile)
