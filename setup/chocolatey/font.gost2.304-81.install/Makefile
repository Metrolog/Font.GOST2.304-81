#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR ?= $(realpath ../../../ITG.MakeUtils)
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/chocolatey.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

CHOCO_PACKAGE_NAME = font.gost2.304-81.install
CHOCO_PACKAGE_INSTALLER = $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/$(notdir $(msiTARGETS))

$(eval $(call copyfile,$(CHOCO_PACKAGE_INSTALLER),$(msiTARGETS)))
$(eval $(call packChocoMSIPackage,CHOCO_FONTS_INSTALL_PACKAGE_,$(CHOCO_PACKAGE_NAME),$(ProductCode),$(MajorMinorPatch),$(CHOCO_PACKAGE_INSTALLER)))

all: choco.fonts.install
choco.fonts.install: $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS)
	$(pushDeploymentArtifact)

.PHONY: test-choco.fonts.install
test-choco.fonts.install: $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS)
	@echo ===============================================================================
	@echo Test "$@": $(CHOCO) install $(CHOCO_PACKAGE_NAME)...
	$(CHOCO) install $(CHOCO_PACKAGE_NAME) --force --confirm -pre --source "$(<D)"
	@echo Test OK.
	@echo ===============================================================================
	@echo Test "$@": $(CHOCO) uninstall $(CHOCO_PACKAGE_NAME)...
	$(CHOCO) uninstall $(CHOCO_PACKAGE_NAME) --confirm
	@echo Test OK.
	@echo ===============================================================================

test: test-choco.fonts.install

clean::
	rm -f $(SOURCESDIR)/$(CHOCO_PACKAGE_NAME)/*.msi
