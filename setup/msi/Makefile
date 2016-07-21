#
# GNU make Makefile
# 

.DEFAULT_GOAL     := all
.PHONY: all

ITG_MAKEUTILS_DIR  ?= ../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

ProjectName       := GOST2.304-81
WIXEXTENSIONS     = WixUIExtension

ttfTARGETS        ?=
otfTARGETS        ?=
FONTFILES         ?= $(ttfTARGETS) $(otfTARGETS)

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msi.mk

export msiTARGETS := $(TargetFullName)
$(eval $(call declareGlobalTargets,msiTARGETS))

all: msi

msi:
	$(pushArtifact)
