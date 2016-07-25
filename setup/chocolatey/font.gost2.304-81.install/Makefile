#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR ?= $(realpath ../../../ITG.MakeUtils)
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/chocolatey.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

ifndef ProductCode
$(error Undefined ProductCode. Run make in $(ROOT_PROJECT_DIR) ($(realpath $(ROOT_PROJECT_DIR)))!)
endif

$(eval $(call packChocoMSIWebPackage,CHOCO_FONTS_INSTALL_PACKAGE_,font.gost2.304-81.install,$(ProductCode),$(MajorMinorPatch),$(msiTARGETS)))

all: choco.fonts.install
choco.fonts.install: $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS)
	$(pushDeploymentArtifact)
