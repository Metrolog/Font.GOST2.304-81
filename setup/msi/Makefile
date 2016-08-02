#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR  ?= ../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk

ProjectName       := GOST2.304-81
export ProductCode:=0FE6159A-9D17-482A-9873-85D4ECBEDA9B
$(eval $(call exportGlobalVariable,ProductCode))
export UpgradeCode:=7C5D2996-34AE-40E7-B53D-643346A9165C
$(eval $(call exportGlobalVariable,UpgradeCode))
WIXEXTENSIONS     = WixUIExtension

ttfTARGETS        ?=
otfTARGETS        ?=
FONTFILES         ?= $(ttfTARGETS) $(otfTARGETS)

DEPENDENCIES      := $(FONTFILES)

include ..\ITG.WixUtils\msi.mk

export msiTARGETS := $(TargetFullName)
$(eval $(call pushArtifactTargets,msiTARGETS))

all: msi

msi:
	$(pushDeploymentArtifact)

$(eval $(call defineTest,check_sign,msi,\
  $$(call SIGNTEST,$$<), \
  $(msiTARGETS) \
))
