#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR  ?= ../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk

ProjectName				:= GOST2.304-81

ttfTARGETS        ?=
FONTFILES         ?= $(ttfTARGETS)

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msm.mk

export msmTARGETS := $(TargetFullName)
$(eval $(call pushArtifactTargets,msmTARGETS))

all: msm

msm:
	$(pushDeploymentArtifact)

$(eval $(call defineTest,check_sign,msm,\
  $$(call SIGNTEST,$$<), \
  $(msmTARGETS) \
))
