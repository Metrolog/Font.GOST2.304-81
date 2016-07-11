#
# GNU make Makefile
# 

.DEFAULT_GOAL     := all

.PHONY: all

ProjectName       := GOST2.304-81
WIXEXTENSIONS     = WixUIExtension

ITG_MAKEUTILS_DIR  ?= ../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

ttfTARGETS        ?=
otfTARGETS        ?=
#FONTFILES         ?= $(foreach file,$(ttfTARGETS) $(otfTARGETS),$(ROOT_PROJECT_DIR)/$(FONTS_DIR)/$(file))
FONTFILES         ?= $(foreach file,$(ttfTARGETS) $(otfTARGETS),$(ROOT_PROJECT_DIR)/$(file))

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msi.mk

all: msi
