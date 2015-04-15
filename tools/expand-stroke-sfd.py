#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

for glyph in font.glyphs():
#	if not ( glyph.background.isEmpty() ):
		glyph.layers[1] += glyph.background
		glyph.layerrefs[1] += glyph.layerrefs[0]
		glyph.layers[0] = fontforge.layer()

for glyph in font.glyphs():
	glyph.stroke ('circular', 100, 'round', 'round', [])
	glyph.removeOverlap ()
	glyph.correctDirection ()
	glyph.simplify (0.4, ['smoothcurves', 'removesingletonpoints', 'ignoreextrema'])
	glyph.addExtrema ('all')
	glyph.simplify (3, ['smoothcurves', 'setstarttoextremum'])
	glyph.round ()
	glyph.canonicalStart ()
	glyph.canonicalContours ()

font.strokedfont = False

font.save (destfile)
