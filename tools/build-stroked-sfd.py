#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge, psMat
import sys, os, re

toolsdir = os.path.dirname(os.path.abspath(sys.argv[0])) + '/'
sourcefile = sys.argv[1]
destfile = sys.argv[2]
version = sys.argv[3]

font = fontforge.open (sourcefile)

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

# add 0-9, +-=() subscript, superscript
subscriptScale = 10.0/14
subscriptTransform = psMat.compose ( psMat.scale(subscriptScale), psMat.translate(0, -500) )
subToSuperscriptTransform = psMat.translate(0, 1400)
sourceUnicode = range(0x30, 0x3A) + [0x002B, 0x2212, 0x003D, 0x0028, 0x0029]
subUnicode = range(0x2080, 0x208F)
superUnicode = [0x2070, 0x00B9, 0x00B2, 0x00B3] + range( 0x2074, 0x207F )
for i in range(len(sourceUnicode)):
	sourceGlyph = font[fontforge.nameFromUnicode( sourceUnicode[i] )]
	subGlyph = font.createMappedChar ( subUnicode[i] )
	superGlyph = font.createMappedChar ( superUnicode[i] )
	subGlyph.width = sourceGlyph.width
	subGlyph.addReference (sourceGlyph.glyphname)
	subGlyph.transform (subscriptTransform)
	superGlyph.width = subGlyph.width
	superGlyph.addReference (subGlyph.glyphname, subToSuperscriptTransform)

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

font.is_quadratic = False

# roman ligatures
font.mergeFeature ( toolsdir + 'roman.fea')

# add numero № ligatures
# http://en.wikipedia.org/wiki/Numero_sign
font.mergeFeature ( toolsdir + 'numero.fea')

font.save (destfile)
