#!/usr/bin/python
# -*- coding: utf-8 -*-

import fontforge
import sys

sourcefile = sys.argv[1]
destfile = sys.argv[2]

font = fontforge.open (sourcefile)

font.save (destfile)
