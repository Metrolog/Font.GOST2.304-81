#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge
import sys
import psMat, math

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

slantAngle = 75-90

font.selection.all ()
font.correctDirection ()
font.transform ( psMat.skew ( math.radians (-slantAngle) ) )
font.round ()
font.canonicalStart()

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
