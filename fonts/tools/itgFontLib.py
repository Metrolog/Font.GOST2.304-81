#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge

def fontPreProcessing ( font ) :
	if fontforge.version() < '20150827' :
		raise RuntimeError( 'Unsupported fontforge version. Must be 20150827 or later.' )

def isFlippedRef ( ref ) :
	return ( ( ref[1][0] != ref[1][3] ) or ( ref[1][1] != 0 ) or ( ref[1][2] != 0 ) )

def isFlippedOrRotatedRef ( ref ) :
	return ( ( ref[1][0] != ref[1][3] ) or ( ref[1][0] < 0 ) or ( ref[1][1] != 0 ) or ( ref[1][2] != 0 ) )

def removeRefsIf ( font, predicat ) :
	for glyph in font.glyphs() :
		mustBeProcessed = False
		for ref in glyph.references :
			if predicat( ref ) :
				glyph.unlinkRef ( ref[0] )
				mustBeProcessed = True
		if mustBeProcessed :
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
