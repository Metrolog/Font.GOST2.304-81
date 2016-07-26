ifndef MAKE_CHOCOLATEY_DIR
MAKE_CHOCOLATEY_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_CHOCOLATEY_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

CHOCO              ?= choco
NUGET              ?= nuget
CHOCOPKGUP         ?= chocopkgup

#OUTPUTDIR         := $(SOURCESDIR)/_output

# $(call calcChocoPackageFileName, packageId, packageVersion)
calcChocoPackageFileName = $1.$2.nupkg

# $(call packChocoWebPackageAux, id, packageId, chocoPkgUpArgs, packageVersion, Dependencies)
define packChocoWebPackageAux

export $(1)TARGETS ?= $(OUTPUTDIR)/$2/$$($(1)VERSION)/$(call calcChocoPackageFileName,$2,$$($(1)VERSION))
$(call declareGlobalTargets,$(1)TARGETS)
$(1)NUSPEC      ?= $(wildcard $(SOURCESDIR)/$2/*.nuspec)
$(1)TOOLS       ?= $(wildcard $(SOURCESDIR)/$2/chocolatey*.ps1)
$(1)VERSION     ?= $4

$$($(1)TARGETS): $$($(1)NUSPEC) $$($(1)TOOLS) $5
	rm -rf $$(@D)
	$$(CHOCOPKGUP) \
    --packagename=$2 \
    $3 \
    --version=$$($(1)VERSION) \
    --packagesfolder="$$(dir $$(<D))" \
    --force \
    --disablepush \
    --debug
	@touch $$@

.PHONY: $1
$(1): $$($(1)TARGETS)

endef

# $(call packChocoWebPackage, id, packageId, packageVersion, Dependencies)
packChocoWebPackage = $(call packChocoWebPackageAux,$1,$2,,$3,$4)

# $(call packChocoMSIWebPackage, id, packageId, productCode, packageVersion, Dependencies)
packChocoMSIWebPackage = $(call packChocoWebPackageAux,$1,$2,--packageguid=$3,$4,$5)

# $(call packChocoPackageAux, id, packageId, installerArgs, packageVersion, preReleaseSuffix, dependencies)
define packChocoPackageAux

export $(1)TARGETS ?= $(OUTPUTDIR)/$2/$$($(1)VERSION)/$(call calcChocoPackageFileName,$2,$$($(1)VERSION))
$(call declareGlobalTargets,$(1)TARGETS)
$(1)NUSPEC      ?= $(wildcard $(SOURCESDIR)/$2/*.nuspec)
$(1)TOOLS       ?= $(wildcard $(SOURCESDIR)/$2/chocolatey*.ps1)
$(1)VERSION     ?= $4
$(1)VERSIONSUFFIX ?= $5
ifneq ($$($(1)VERSIONSUFFIX),)
$(1)VERSIONSUFFIXARG := -Suffix $$($(1)VERSIONSUFFIX)
endif

$$($(1)TARGETS): $$($(1)NUSPEC) $$($(1)TOOLS) $6
	$$(info Generate chocolatey package file "$$@"...)
	$$(MAKETARGETDIR)
	$$(NUGET) \
    pack $$< \
    -OutputDirectory $$(@D) \
    -Version $$($(1)VERSION) \
    $$($(1)VERSIONSUFFIXARG) \
    -Verbosity detailed \
    -NoPackageAnalysis \
    -NonInteractive
	@touch $$@

.PHONY: $1
$(1): $$($(1)TARGETS)

endef

# $(call packChocoMSIPackage, id, packageId, productCode, packageVersion, preReleaseSuffix, dependencies)
packChocoMSIPackage = $(call packChocoPackageAux,$1,$2,,$4,$5,$6)

endif