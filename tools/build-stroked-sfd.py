#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge, psMat
import sys, os, re

toolsdir = os.path.dirname(os.path.abspath(sys.argv[0])) + '/'
sourcefile = sys.argv[1]
destfile = sys.argv[2]
version = sys.argv[3]

font = fontforge.open (sourcefile)

font.is_quadratic = False

kernSubtables = reduce (lambda a, b: a + b , [ font.getLookupSubtables(lookup) for lookup in font.gpos_lookups if font.getLookupInfo( lookup )[0] == 'gpos_pair' ] )

for glyph in font.glyphs():
	if not ( glyph.background.isEmpty ):
		glyph.foreground += glyph.background
		glyph.background = fontforge.layer()

# set font version
font.version = version
ver = re.search('^(?P<major>\d+)\.(?P<minor>\d+)(\.(?P<release>\d+)(\.(?P<build>\d+))?)?', version)
if ver is not None:
	font.sfntRevision = None
	for name in font.sfnt_names:
		if name[1] == 'Version':
			font.appendSFNTName (name[0], name[1], '')
	font.appendSFNTName ( 'English (US)', 'Version', font.version )

# unlink transformed references
for glyph in font.glyphs():
	for ref in glyph.references:
		if ( (ref[1][0]!=1) or (ref[1][1]!=0) or (ref[1][2]!=0) or (ref[1][3]!=1)):
			glyph.unlinkRef ()
	if ( (glyph.unlinkRmOvrlpSave) or ( (len(glyph.foreground)>0) and (len(glyph.references)>0) ) ):
		glyph.unlinkRef ()
		glyph.unlinkRmOvrlpSave = False

font.encoding = 'unicode'

# additional glyphs for marks
for markData in [
	[0x0300, 0x0060, 0x02CB] # grave
	, [0x0301, 0x00B4, 0x02CA] # acute
	, [0x0302, 0x005E, 0x02C6] # circumflex
	, [0x0303, 0x007E, 0x02DC] # tilde
	, [0x0304, 0x00AF, 0x02C9] # macron
	, [0x0306, 0x02D8] # breve
	, [0x0307, 0x02D9] # dot above
	, [0x0308, 0x00A8] # diaeresis
	]:
	if font.findEncodingSlot (markData[0]) > -1:
		sourceGlyph = font[markData[0]]
		for i in range(1, len(markData)):
			if font.findEncodingSlot ( markData[i] ) not in font:
				markGlyph = font.createMappedChar ( markData[i] )
				markGlyph.width =  100 + sourceGlyph.width - sourceGlyph.right_side_bearing - sourceGlyph.left_side_bearing
				markGlyph.addReference ( sourceGlyph.glyphname, psMat.translate( 50 - sourceGlyph.left_side_bearing, 0 ) )

# add 0-9, +-=() subscript, superscript
subscriptScale = 10.0/14
subscriptTransform = psMat.compose ( psMat.scale(subscriptScale), psMat.translate(0, -500) )
subToSuperscriptTransform = psMat.translate(0, 1400)
sourceUnicode = range(0x30, 0x3A) + [0x002B, 0x2212, 0x003D, 0x0028, 0x0029]
subUnicode = range(0x2080, 0x208F)
superUnicode = [0x2070, 0x00B9, 0x00B2, 0x00B3] + range( 0x2074, 0x207F )
for i in range(len(sourceUnicode)):
	sourceGlyph = font[fontforge.nameFromUnicode( sourceUnicode[i] )]
	if font.findEncodingSlot ( subUnicode[i] ) not in font:
		subGlyph = font.createMappedChar ( subUnicode[i] )
		subGlyph.width = sourceGlyph.width
		subGlyph.addReference (sourceGlyph.glyphname)
		subGlyph.transform (subscriptTransform)
		for k in reduce( lambda a, b: a + b, [ sourceGlyph.getPosSub( kernSubtable ) for kernSubtable in kernSubtables ]):
			pairGlyphUnicode = fontforge.unicodeFromName ( k[2] )
			if pairGlyphUnicode in sourceUnicode:
				pairGlyphUnicode = subUnicode[ sourceUnicode.index( pairGlyphUnicode ) ]
				subGlyph.addPosSub ( k[0], fontforge.nameFromUnicode( pairGlyphUnicode ),
					k[3] * subscriptScale, k[4] * subscriptScale, k[5] * subscriptScale, k[6] * subscriptScale,
					k[7] * subscriptScale, k[8] * subscriptScale, k[9] * subscriptScale, k[10] * subscriptScale )
	if font.findEncodingSlot ( superUnicode[i] ) not in font:
		subGlyph = font.createMappedChar ( subUnicode[i] )
		superGlyph = font.createMappedChar ( superUnicode[i] )
		superGlyph.width = subGlyph.width
		superGlyph.addReference (subGlyph.glyphname, subToSuperscriptTransform)
		for k in reduce( lambda a, b: a + b, [ subGlyph.getPosSub( kernSubtable ) for kernSubtable in kernSubtables ]):
			pairGlyphUnicode = fontforge.unicodeFromName ( k[2] )
			if pairGlyphUnicode in subUnicode:
				pairGlyphUnicode = superUnicode[ subUnicode.index( pairGlyphUnicode ) ]
				superGlyph.addPosSub ( k[0], fontforge.nameFromUnicode( pairGlyphUnicode ),
					k[3], k[4], k[5], k[6], k[7], k[8], k[9], k[10] )

# add slashed zero support for subscript and superscript
normalSourceGlyph = font[fontforge.nameFromUnicode( sourceUnicode[0] )]
if font.findEncodingSlot (normalSourceGlyph.glyphname + '.SlashedZero') > -1:
	sourceGlyph = font[normalSourceGlyph.glyphname + '.SlashedZero']
	normalSubGlyph = font[fontforge.nameFromUnicode( subUnicode[0] )]
	subGlyph = font.createChar ( -1, normalSubGlyph.glyphname + '.SlashedZero' )
	normalSuperGlyph = font[fontforge.nameFromUnicode( superUnicode[0] )]
	superGlyph = font.createChar ( -1, normalSuperGlyph.glyphname + '.SlashedZero' )
	subGlyph.width = sourceGlyph.width
	subGlyph.addReference (sourceGlyph.glyphname)
	subGlyph.transform (subscriptTransform)
	superGlyph.width = subGlyph.width
	superGlyph.addReference (subGlyph.glyphname, subToSuperscriptTransform)
	subtableName = "Slashed Zero"
	if font.getLookupOfSubtable (subtableName) is not None:
		normalSourceGlyph.addPosSub (subtableName, sourceGlyph.glyphname)
		normalSubGlyph.addPosSub (subtableName, subGlyph.glyphname)
		normalSuperGlyph.addPosSub (subtableName, superGlyph.glyphname)

# add alternative 3 support for subscript and superscript
normalSourceGlyph = font[fontforge.nameFromUnicode( sourceUnicode[3] )]
if font.findEncodingSlot (normalSourceGlyph.glyphname + '.AltThree') > -1:
	sourceGlyph = font[normalSourceGlyph.glyphname + '.AltThree']
	normalSubGlyph = font[fontforge.nameFromUnicode( subUnicode[3] )]
	subGlyph = font.createChar ( -1, normalSubGlyph.glyphname + '.AltThree' )
	normalSuperGlyph = font[fontforge.nameFromUnicode( superUnicode[3] )]
	superGlyph = font.createChar ( -1, normalSuperGlyph.glyphname + '.AltThree' )
	subGlyph.width = sourceGlyph.width
	subGlyph.addReference (sourceGlyph.glyphname)
	subGlyph.transform (subscriptTransform)
	superGlyph.width = subGlyph.width
	superGlyph.addReference (subGlyph.glyphname, subToSuperscriptTransform)
	subtableName = "Alternative Three"
	if font.getLookupOfSubtable (subtableName) is not None:
		normalSourceGlyph.addPosSub (subtableName, sourceGlyph.glyphname)
		normalSubGlyph.addPosSub (subtableName, subGlyph.glyphname)
		normalSuperGlyph.addPosSub (subtableName, superGlyph.glyphname)

# build capitalized roman digits
if font.findEncodingSlot (0x2160) not in font:
	font.selection.select ( ['ranges', 'unicode'], 0x2160, 0x216F )
	font.build()

# create small roman digits as a copy of capitalized roman digits
if font.findEncodingSlot (0x2170) not in font:
	sourceUnicode = range(0x2160, 0x2170)
	destUnicode = range(0x2170, 0x2180)
	for i in range(len(sourceUnicode)):
		sourceGlyph = font[ fontforge.nameFromUnicode( sourceUnicode[i] ) ]
		destGlyph = font.createMappedChar ( destUnicode[i] )
		destGlyph.addReference (sourceGlyph.glyphname)
		destGlyph.useRefsMetrics (sourceGlyph.glyphname)
		for k in reduce( lambda a, b: a + b, [ sourceGlyph.getPosSub( kernSubtable ) for kernSubtable in kernSubtables ]):
			pairGlyphUnicode = fontforge.unicodeFromName ( k[2] )
			if ( pairGlyphUnicode >= 0x2160 ) and ( pairGlyphUnicode <= 0x216F ):
				pairGlyphUnicode += 0x10
			destGlyph.addPosSub ( k[0], fontforge.nameFromUnicode( pairGlyphUnicode ), k[3], k[4], k[5], k[6], k[7], k[8], k[9], k[10] )

# roman ligatures
font.mergeFeature ( toolsdir + 'roman.fea')

# add numero № ligatures
# http://en.wikipedia.org/wiki/Numero_sign
font.mergeFeature ( toolsdir + 'numero.fea')

font.save (destfile)
