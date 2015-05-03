#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge, psMat
import sys, os, re
from itertools import groupby
import collections

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
#	if not ( glyph.background.isEmpty() ):
		glyph.layers[1] += glyph.background
		glyph.layerrefs[1] += glyph.layerrefs[0]
		glyph.layers[0] = fontforge.layer()

kernLookup = 'common_kerning'
kernSize = 200
minKern = 20
classDiff = 10
onlyCloser = True
touch = False 

def glyphNamesInRange ( font, unicodeRange ):
	return [ font[ code ].glyphname for code in unicodeRange if code in font ]

digits = [ font[ code ].glyphname for code in xrange(0x30, 0x3A) ]
allDigits = digits + [ 'three.alt', 'zero.slash' ]

ordGlyphs = [ 'ordfeminine', 'ordmasculine' ]
digitSeparators = [ 'period', 'comma' ]
primes = glyphNamesInRange( font, ( 0x2032, 0x2033, 0x2034 ) )
degree = [ 'degree' ]
degreeAll = degree

leftBrackets = glyphNamesInRange( font, ( 0x0028, 0x005B, 0x007B ) )
rightBrackets = glyphNamesInRange( font, ( 0x0029, 0x005D, 0x007D ) )

latinCapitalLetters = glyphNamesInRange( font, xrange( font['A'].unicode, font['Z'].unicode + 1 ) )
latinAllCapitalLetters = latinCapitalLetters + [ 'AE', 'Oslash', 'OE', 'Lslash' ]
latinSmallLetters = glyphNamesInRange( font, xrange( font['a'].unicode, font['z'].unicode + 1 ) )
latinAllSmallLetters = latinSmallLetters + [ 'germandbls', 'ae', 'oslash', 'oe', 'dotlessi', 'lslash' ] + glyphNamesInRange( font, [ 0x0237 ] )
latinLetters = latinCapitalLetters + latinSmallLetters
latinAllLetters = latinAllCapitalLetters + latinAllSmallLetters

cyrCapitalLetters = glyphNamesInRange( font, range( 0x0410, 0x042F + 1 ) + [ 0x0401 ] )
cyrAllCapitalLetters =  cyrCapitalLetters
cyrSmallLetters = glyphNamesInRange( font, range( 0x0430, 0x044F + 1 ) + [ 0x0451 ] )
cyrAllSmallLetters = cyrSmallLetters
cyrLetters = cyrCapitalLetters + cyrSmallLetters
cyrAllLetters = cyrAllCapitalLetters + cyrAllSmallLetters

greekCapitalLetters = glyphNamesInRange( font, xrange( 0x0391, 0x03A9 + 1 ) )
greekAllCapitalLetters =  greekCapitalLetters
greekSmallLetters = glyphNamesInRange( font, xrange( 0x03B1, 0x03C9 + 1 ) )
greekAllSmallLetters = greekSmallLetters
greekLetters = greekCapitalLetters + greekSmallLetters
greekAllLetters = greekAllCapitalLetters + greekAllSmallLetters

allLetters = cyrAllLetters + latinAllLetters + greekAllLetters

punctuation = [ 'period', 'comma' ]

font.addKerningClass( kernLookup, 'numbers_kerning', kernSize, classDiff, allDigits + digitSeparators, allDigits + digitSeparators, onlyCloser, True )
font.addKerningClass( kernLookup, 'digits_ord_kerning', kernSize, classDiff, allDigits, ordGlyphs, onlyCloser, True )
font.addKerningClass( kernLookup, 'digits_percent_kerning', kernSize, classDiff, allDigits, ( 'percent', 'perthousand', 'uni2031' ), onlyCloser, True )
font.addKerningClass( kernLookup, 'primes_kerning', kernSize, classDiff, allDigits + latinAllLetters + greekAllLetters, primes, onlyCloser, True )
font.addKerningClass( kernLookup, 'digits_degree_kerning', kernSize, classDiff, allDigits, degreeAll, onlyCloser, True )
font.addKerningClass( kernLookup, 'brackets_left_kerning', kernSize, classDiff, leftBrackets, allDigits + allLetters, onlyCloser, True )
font.addKerningClass( kernLookup, 'brackets_right_kerning', kernSize, classDiff, allDigits + allLetters, rightBrackets, onlyCloser, True )
font.addKerningClass( kernLookup, 'latin_kerning', kernSize, classDiff, latinAllLetters, latinAllLetters + punctuation, onlyCloser, True )
font.addKerningClass( kernLookup, 'cyr_kerning', kernSize, classDiff, cyrAllLetters, cyrAllLetters + punctuation, onlyCloser, True )

def kernOffsetPostProcessing ( offset ):
	return ( -100 if offset < -60 else 0 )

KerningClass = collections.namedtuple( 'KerningClass', [ 'glyphs', 'offsets' ] )

def reduceDupClasses ( classes ):
	newClasses = []
	for cls in classes:
		isDupClass = False
		for i, exCls in enumerate( newClasses ):
			if ( cls.offsets == exCls.offsets ):
				isDupClass = True
				newClasses[i] = KerningClass(
					glyphs = None if ( ( exCls.glyphs is None ) or ( cls.glyphs is None ) ) else cls.glyphs + exCls.glyphs,
					offsets = exCls.offsets
				)
		if ( not isDupClass ):
			newClasses += [ cls ]
	return newClasses

for subtable in font.getLookupSubtables( kernLookup ):
	if font.isKerningClass( subtable ):
		clKern = font.getKerningClass( subtable )
		font.alterKerningClass( subtable, clKern[0], clKern[1], [ kernOffsetPostProcessing( offset ) for offset in clKern[2] ] )
		clKern = font.getKerningClass( subtable )
		glyphClasses = reduceDupClasses ( [ 
			KerningClass(
				glyphs = cl, 
				offsets = [ clKern[2][offsetIndex] for offsetIndex in xrange( i * len( clKern[1] ), ( i + 1 ) * len( clKern[1] ) ) ]
			) for i, cl in enumerate( clKern[0] )
		] )
		font.alterKerningClass(
			subtable,
			[ cls.glyphs for cls in glyphClasses ],
			clKern[1],
			reduce( list.__add__, [ cls.offsets for cls in glyphClasses ] )
		)
		clKern = font.getKerningClass( subtable )
		glyphClasses = reduceDupClasses( [ 
			KerningClass(
				glyphs = cl, 
				offsets = [ clKern[2][offsetIndex] for offsetIndex in xrange( i, len( clKern[2] ), len( clKern[1] ) ) ]
			) for i, cl in enumerate( clKern[1] )
		] )
		font.alterKerningClass(
			subtable,
			clKern[0],
			[ cls.glyphs for cls in glyphClasses ],
			reduce( list.__add__, [ [ cls.offsets[i] for cls in glyphClasses ] for i in range( len( clKern[0] ) ) ] )
		)
	else:
		newKernPairs = ()
		for glyph in font.glyphs():
			for k in glyph.getPosSub( subtable ):
				newKern = kernOffsetPostProcessing( k[5] )
				if ( newKern != 0 ):
					newKernPairs += ( ( k[2], newKern ), )
			glyph.removePosSub( subtable )
			for kernPair in newKernPairs:
				glyph.addPosSub ( subtable, kernPair[0], kernPair[1] )

font.save (destfile)
