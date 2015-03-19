#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge
import sys
import psMat, math

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
	if not ( glyph.background.isEmpty ):
		glyph.foreground += glyph.background
		glyph.background = fontforge.layer()

slantAngle = 75-90

transformation = psMat.skew ( math.radians (-slantAngle) )

font.selection.none ()
font.selection.select (['more', 'unicode', 'singletons'], 0x2031, 0x26AC, 0x030A, 0x2300, 0x2332, 0x2218, 0x2219, 0x2316, 0x232D, 0x23E5, 0x27C2)
font.selection.select (['more', 'singletons'], 'percent', 'perthousand', 'slash', 'degree', 'perpendicular', '.notdef', '.null', 'nonmarkingreturn')
font.selection.select (['more', 'unicode', 'ranges'], 0x2500, 0x25FF)
#for glyph in font.selection.byGlyphs:
#	bounds = glyph.boundingBox()
#	dx = fontforge.point(0, bounds[3]+50).transform(transformation).x
#	glyph.transform ( psMat.translate( dx, 0 ), ['partialRefs', None] )

font.selection.invert ()
for glyph in font.selection.byGlyphs:
	glyph.correctDirection ()
	glyph.transform ( transformation, ['partialRefs', None]  )
	glyph.round ()
	glyph.canonicalStart()

font.italicangle = slantAngle
font.macstyle = 2
#SetTeXParams( GetTeXParam(-1), GetTeXParam(0), slantAngle, GetTeXParam(2), GetTeXParam(3), GetTeXParam(4), GetTeXParam(5), GetTeXParam(6), GetTeXParam(7))

font.fullname += " Slanted"
font.appendSFNTName ('English (US)', 'SubFamily', 'Italic')
font.appendSFNTName (0x419, 'SubFamily', 'Наклонный')

for name in font.sfnt_names:
	if name[1] == 'Fullname':
		font.appendSFNTName (name[0], name[1], 
			name[2] + ' ' + [iname[2] for iname in font.sfnt_names if (iname[0] == name[0]) and (iname[1] == 'SubFamily')][0])

font.save (destfile)
