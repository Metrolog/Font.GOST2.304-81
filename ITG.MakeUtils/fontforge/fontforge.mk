ifndef MAKE_FONTFORGE_CTAN_DIR
MAKE_FONTFORGE_CTAN_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_FONTFORGE_CTAN_DIR)/..)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk

TOOLSDIR           ?= tools/
FONTSTOOLSLIBS     := $(TOOLSDIR)itgFontLib.py

FONTFORGE          ?= fontforge \
	-nosplash

ifeq ($(OS),Windows_NT)
PY                 ?= ffpython
else
PY                 ?= python
endif

AUTOHINT           ?= ttfautohint
TTFAUTOHINT        ?= \
  $(TOOLSDIR)ttfautohint \
    --hinting-range-min=8 \
    --hinting-range-max=88 \
    --hinting-limit=220 \
    --increase-x-height=22 \
    --windows-compatibility \
    --composites \
    --strong-stem-width="gGD" \
    --no-info
FASTFONT           ?= fastfont

endif