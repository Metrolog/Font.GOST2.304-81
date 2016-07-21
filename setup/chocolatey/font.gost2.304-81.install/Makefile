#
# GNU make Makefile
# 

ITG_MAKEUTILS_DIR  ?= ../../../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk

CHOCO              ?= choco
NUGET              ?= nuget



NUGET_PACKAGES_CONFIG  ?= packages.config
NUGET_PACKAGES_DIR     ?= packages


$(NUGET_PACKAGES_DIR)/%: ;
	$(NUGET) \
    install $(NUGET_PACKAGES_CONFIG) \
    -OutputDirectory $(NUGET_PACKAGES_DIR) \
    -ExcludeVersion


WARMUP             ?= $(NUGET_PACKAGES_DIR)/warmup/bin/warmup


CHOCOPKGUP         ?= chocopkgup


OUTPUTDIR          := $(SOURCESDIR)/_output

# $(call calcChocoPackageFileName, packageId, packageVersion)
calcChocoPackageFileName = $1.$2.nupkg

# $(call packChocoWebPackage, id, packageId, packageVersion, Dependencies)
define packChocoWebPackage

export $(1)TARGETS := $(OUTPUTDIR)/$2/$$($(1)VERSION)/$(call calcChocoPackageFileName,$2,$$($(1)VERSION))
$(call declareGlobalTargets,$(1)TARGETS)
$(1)NUSPEC      ?= $(wildcard $(SOURCESDIR)/$2/*.nuspec)
$(1)TOOLS       ?= $(wildcard $(SOURCESDIR)/$2/chocolatey*.ps1)
$(1)VERSION     ?= $3

$$($(1)TARGETS): $$($(1)NUSPEC) $$($(1)TOOLS) $4
	rm -rf $$(@D)
	$$(CHOCOPKGUP) \
    --package=$2 \
    --version=$$($(1)VERSION) \
    --packagesfolder="$$(dir $$(<D))" \
    --force \
    --disablepush \
    --debug
	@touch $$@

#	$$(NUGET) pack $$< -OutputDirectory $$(@D) -Version $$($(1)VERSION) -Verbosity detailed -NoPackageAnalysis -NonInteractive -Properties a=1;b=2;c=3

.PHONY: $1
$(1): $$($(1)TARGETS)

endef

#$(info ============================)
#$(info $(call packChocoWebPackage,CHOCO_FONTS_INSTALL_PACKAGE_,font.gost2.304-81.install,$(MajorMinorPatch),$(msiTARGETS)))
#$(info ============================)
$(eval $(call packChocoWebPackage,CHOCO_FONTS_INSTALL_PACKAGE_,font.gost2.304-81.install,$(MajorMinorPatch),$(msiTARGETS)))

.PHONY: choco.fonts.install
all: choco.fonts.install
choco.fonts.install: $(CHOCO_FONTS_INSTALL_PACKAGE_TARGETS)
