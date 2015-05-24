#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge

def fontPreProcessing ( font ) :
	for glyph in font.glyphs():
	#	if not ( glyph.background.isEmpty() ):
			glyph.layers[1] += glyph.background
			glyph.layerrefs[1] += glyph.layerrefs[0]
			glyph.layers[0] = fontforge.layer()

def removeFlippedRefs ( font ) :
	for glyph in font.glyphs() :
		mustBeProcessed = False
		for ref in glyph.references :
			if ( ( ref[1][0] != ref[1][3] ) or ( ref[1][1] != 0 ) or ( ref[1][2] != 0 ) ) :
				mustBeProcessed = True
		if mustBeProcessed :
			glyph.unlinkRef ()
			glyph.correctDirection ()
			glyph.round ()
			glyph.canonicalStart ()
			glyph.canonicalContours ()
