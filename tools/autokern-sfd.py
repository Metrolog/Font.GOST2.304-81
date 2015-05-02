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

def autoKern ( font, glyphs, rightGlyps = None, kernSize = 200, minKern = 20, onlyCloser = True, touch = False ):
	if ( rightGlyps is None ):
		rightGlyps = glyphs
	font.autoKern( kernSubtable, kernSize, glyphs, rightGlyps, minKern = minKern, onlyCloser = onlyCloser, touch = touch )

digits = [ font[ code ].glyphname for code in range(0x30, 0x3A) ]
allDigits = digits + [ 'three.alt', 'zero.slash' ]
digitSeparators = [ 'period', 'comma' ]
autoKern( font, allDigits + digitSeparators )

latinCapitalLetters = [ font[ code ].glyphname for code in range( font['A'].unicode, font['Z'].unicode + 1 ) ]
latinAllCapitalLetters = latinCapitalLetters
latinSmallLetters = [ font[ code ].glyphname for code in range( font['a'].unicode, font['z'].unicode + 1 ) ]
latinAllSmallLetters = latinSmallLetters
latinLetters = latinCapitalLetters + latinSmallLetters
latinAllLetters = latinAllCapitalLetters + latinAllSmallLetters

punctuation = [ 'period', 'comma' ]

autoKern( font, latinAllLetters )
autoKern( font, latinAllLetters, punctuation )
autoKern( font, latinAllCapitalLetters, allDigits )

cyrCapitalLetters = [ font[ code ].glyphname for code in range( 0x0410, 0x042F + 1 ) + [ 0x0401 ] ]
cyrAllCapitalLetters =  cyrCapitalLetters
cyrSmallLetters = [ font[ code ].glyphname for code in range( 0x0430, 0x044F + 1 ) + [ 0x0451 ] ]
cyrAllSmallLetters = cyrSmallLetters
cyrLetters = cyrCapitalLetters + cyrSmallLetters
cyrAllLetters = cyrAllCapitalLetters + cyrAllSmallLetters

autoKern( font, cyrAllLetters )
autoKern( font, cyrAllLetters, punctuation )
autoKern( font, cyrAllCapitalLetters, allDigits )

for glyph in font.glyphs():
	for k in glyph.getPosSub( kernSubtable ):
		glyph.addPosSub ( kernSubtable, k[2], -100 if k[5] < -100 else k[5] )

font.save (destfile)
