#
# GNU make Makefile
# 

.DEFAULT_GOAL			:= all
.PHONY: all

ITG_MAKEUTILS_DIR  ?= ../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

ProjectName				:= GOST2.304-81

ttfTARGETS        ?=
FONTFILES         ?= $(ttfTARGETS)

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msm.mk

all: msm
