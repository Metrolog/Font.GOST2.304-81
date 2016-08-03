#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR ?= $(realpath ../../../ITG.MakeUtils)
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/chocolatey.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

CHOCO_PACKAGE_NAME = font.gost2.304-81.install
CHOCO_PACKAGE_INSTALLER = $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/setup.msi

$(eval $(call copyfile,$(CHOCO_PACKAGE_INSTALLER),$(msiTARGETS)))
$(eval $(call packChocoMSIPackage,CHOCO_FONTS_INSTALL_PACKAGE_,$(CHOCO_PACKAGE_NAME),$(ProductCode),$(MajorMinorPatch),$(PreReleaseLabel),$(CHOCO_PACKAGE_INSTALLER)))

all: choco.fonts.install
choco.fonts.install: $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS)
	$(pushDeploymentArtifact)

$(eval $(call defineTest,install,choco.fonts.install,\
  $(CHOCO) install $(CHOCO_PACKAGE_NAME) --force --confirm -pre --source "$$(<D)", \
  $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS) \
))

$(eval $(call defineTest,uninstall,choco.fonts.install,\
  $(CHOCO) uninstall $(CHOCO_PACKAGE_NAME) --confirm, \
  $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS) \
))

clean::
	rm -f $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/*.msi
