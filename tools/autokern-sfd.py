#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge, psMat
import sys, os, re

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
#	if not ( glyph.background.isEmpty() ):
		glyph.layers[1] += glyph.background
		glyph.layerrefs[1] += glyph.layerrefs[0]
		glyph.layers[0] = fontforge.layer()

kernSubtable = 'common_kerning subtable'

digitsNames = [ font[ code ].glyphname for code in range(0x30, 0x3A) ]
allDigitsNames = digitsNames + [ 'three.alt', 'zero.slash' ]
font.autoKern( kernSubtable, 300, allDigitsNames, allDigitsNames, minKern = 20, onlyCloser = True, touch = False )

for glyph in font.glyphs():
	for k in glyph.getPosSub( kernSubtable ):
		glyph.addPosSub ( kernSubtable, k[2], -100 if k[5] < -100 else k[5] )

font.save (destfile)
