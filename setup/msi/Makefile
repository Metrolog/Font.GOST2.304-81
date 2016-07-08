#
# GNU make Makefile
# 

.DEFAULT_GOAL     := all

.PHONY: all

ProjectName       := GOST2.304-81
WIXEXTENSIONS     = WixUIExtension

ttfTARGETS        ?=
otfTARGETS        ?=
FONTFILES         ?= $(foreach file,$(ttfTARGETS) $(otfTARGETS),$(FONTPRJDIR)$(file))

ifdef $(FONTPRJDIR)

$(FONTPRJDIR)%:
	$(MAKE) -C $(FONTPRJDIR) $*

endif

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msi.mk

all: msi
