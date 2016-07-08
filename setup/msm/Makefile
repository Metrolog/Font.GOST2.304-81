#
# GNU make Makefile
# 

.DEFAULT_GOAL			:= all

.PHONY: all

ProjectName				:= GOST2.304-81

ttfTARGETS        ?=
FONTFILES         ?= $(foreach file,$(ttfTARGETS) ,$(FONTPRJDIR)$(file))

ifdef $(FONTPRJDIR)

$(FONTPRJDIR)%:
	$(MAKE) -C $(FONTPRJDIR) $*

endif

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msm.mk

all: msm
