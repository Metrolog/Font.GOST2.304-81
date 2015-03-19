#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge
import sys
import psMat, math

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
	glyph.foreground += glyph.background

slantAngle = 75-90

font.selection.all ()
font.selection.select (['less', 'unicode', 'singletons'], 0x26AC, 0x030A, 0x2300, 0x2332, 0x2218, 0x2219, 0x2316, 0x232D, 0x23E5, 0x27C2)
font.selection.select (['less', 'singletons'], 'percent', 'slash', 'degree', 'perpendicular', '.notdef', '.null', 'nonmarkingreturn')
font.selection.select (['less', 'unicode', 'ranges'], 0x2500, 0x25FF)

for glyph in font.selection.byGlyphs:
	glyph.correctDirection ()
	glyph.transform ( psMat.skew ( math.radians (-slantAngle) ), ['partialRefs', None]  )
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
