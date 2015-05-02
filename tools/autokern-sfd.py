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

def glyphNamesInRange ( font, unicodeRange ):
	return [ font[ code ].glyphname for code in unicodeRange if code in font ]

digits = [ font[ code ].glyphname for code in range(0x30, 0x3A) ]
allDigits = digits + [ 'three.alt', 'zero.slash' ]

ordGlyphs = [ 'ordfeminine', 'ordmasculine' ]
digitSeparators = [ 'period', 'comma' ]
primes = glyphNamesInRange( font, [ 0x2032, 0x2033, 0x2034 ] )

leftBrackets = glyphNamesInRange( font, [ 0x0028, 0x005B, 0x007B ] )
rightBrackets = glyphNamesInRange( font, [ 0x0029, 0x005D, 0x007D ] )

latinCapitalLetters = glyphNamesInRange( font, range( font['A'].unicode, font['Z'].unicode + 1 ) )
latinAllCapitalLetters = latinCapitalLetters + [ 'AE', 'Oslash', 'OE', 'Lslash' ]
latinSmallLetters = glyphNamesInRange( font, range( font['a'].unicode, font['z'].unicode + 1 ) )
latinAllSmallLetters = latinSmallLetters + [ 'germandbls', 'ae', 'oslash', 'oe', 'dotlessi', 'lslash' ] + [ font[ code ].glyphname for code in [ 0x0237 ] ]
latinLetters = latinCapitalLetters + latinSmallLetters
latinAllLetters = latinAllCapitalLetters + latinAllSmallLetters

cyrCapitalLetters = glyphNamesInRange( font, range( 0x0410, 0x042F + 1 ) + [ 0x0401 ] )
cyrAllCapitalLetters =  cyrCapitalLetters
cyrSmallLetters = glyphNamesInRange( font, range( 0x0430, 0x044F + 1 ) + [ 0x0451 ] )
cyrAllSmallLetters = cyrSmallLetters
cyrLetters = cyrCapitalLetters + cyrSmallLetters
cyrAllLetters = cyrAllCapitalLetters + cyrAllSmallLetters

greekCapitalLetters = glyphNamesInRange( font, range( 0x0391, 0x03A9 + 1 ) )
greekAllCapitalLetters =  greekCapitalLetters
greekSmallLetters = glyphNamesInRange( font, range( 0x03B1, 0x03C9 + 1 ) )
greekAllSmallLetters = greekSmallLetters
greekLetters = greekCapitalLetters + greekSmallLetters
greekAllLetters = greekAllCapitalLetters + greekAllSmallLetters

allLetters = cyrAllLetters + latinAllLetters + greekAllLetters

punctuation = [ 'period', 'comma' ]

autoKern( font, allDigits + digitSeparators )
autoKern( font, allDigits, ordGlyphs )
autoKern( font, allDigits, [ 'percent', 'perthousand', 'uni2031' ] )
autoKern( font, allDigits, primes + [ 'degree' ] )
autoKern( font, leftBrackets, allDigits )
autoKern( font, leftBrackets, allLetters )
autoKern( font, allDigits, rightBrackets )
autoKern( font, allLetters, rightBrackets )
autoKern( font, latinAllLetters )
autoKern( font, latinAllLetters, punctuation )
autoKern( font, latinAllCapitalLetters, allDigits )
autoKern( font, cyrAllLetters )
autoKern( font, cyrAllLetters, punctuation )
autoKern( font, cyrAllCapitalLetters, allDigits )
autoKern( font, latinAllLetters + greekAllLetters, primes )

for glyph in font.glyphs():
	for k in glyph.getPosSub( kernSubtable ):
		glyph.addPosSub ( kernSubtable, k[2], -100 if k[5] < -100 else k[5] )

font.save (destfile)
