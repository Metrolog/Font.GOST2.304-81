#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge, psMat
import sys, re

sourcefile = sys.argv[1]
destfile = sys.argv[2]
version = sys.argv[3]

font = fontforge.open (sourcefile)

# set font version
font.version = version
ver = re.search('^(?P<major>\d+)\.(?P<minor>\d+)(\.(?P<release>\d+)(\.(?P<build>\d+))?)?', version)
if ver is not None:
	font.sfntRevision = ( int(ver.group('major')) << 16 ) + ( int(ver.group ('minor')) )
	for name in font.sfnt_names:
		if name[1] == 'Version':
			font.appendSFNTName (name[0], name[1], '')
	font.appendSFNTName ( 'English (US)', 'Version', font.version )

# unlink transformed references
for glyph in font.glyphs():
	for ref in glyph.references:
		if ( (ref[1][0]!=1) or (ref[1][1]!=0) or (ref[1][2]!=0) or (ref[1][3]!=1)):
			glyph.unlinkRef ()

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

font.save (destfile)