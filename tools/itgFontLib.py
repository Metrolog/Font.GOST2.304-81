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

def scaleEM ( font, em ) :
	xheight = font.os2_xheight
	capheight = font.os2_capheight
	scale = em / font.em
	font.em = em
	font.os2_xheight = xheight * scale
	font.os2_capheight = capheight * scale

def resetGlyphNames ( font, names = 'AGL For New Fonts' ) :
	for glyph in font :
		if font[ glyph ].unicode != -1 :
			font[ glyph ].glyphname = fontforge.nameFromUnicode( font[ glyph ].unicode, names )
