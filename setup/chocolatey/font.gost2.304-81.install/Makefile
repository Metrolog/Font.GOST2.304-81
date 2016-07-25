#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR ?= $(realpath ../../../ITG.MakeUtils)
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/chocolatey.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

$(eval $(call packChocoMSIWebPackage,CHOCO_FONTS_INSTALL_PACKAGE_,font.gost2.304-81.install,0FE6159A-9D17-482A-9873-85D4ECBEDA9B,$(MajorMinorPatch),$(msiTARGETS)))

all: choco.fonts.install
choco.fonts.install: $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS)
	$(pushDeploymentArtifact)
