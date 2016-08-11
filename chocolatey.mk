ifndef MAKE_CHOCOLATEY_DIR
MAKE_CHOCOLATEY_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_CHOCOLATEY_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)
include $(realpath $(ITG_MAKEUTILS_DIR)/tests.mk)

CHOCO              ?= choco
NUGET              ?= nuget
FILEHASHALGORITHM  ?= md5

# $(call getExternalFileId,externalFileXml)
getExternalFileId = $(patsubst %.externalfile.xml,%,$(notdir $1))

# $(call getChocoPackageWebFileChecksumTarget,externalFileXml,bitsPrefix)
getChocoPackageWebFileChecksumTarget = $(call getExternalFileId,$1)_CHECKSUM$(2)

CHOCO_PACKAGE_WEBFILES_AUXDIR ?= $(AUXDIR)/webfiles

# $(call getChocoPackageWebFileChecksumAuxFile,externalFileXml,bitsPrefix)
getChocoPackageWebFileChecksumAuxFile = $(call getExternalFileId,$1)_AUXFILE$(2)

$(CHOCO_PACKAGE_WEBFILES_AUXDIR)/%:
	$(MAKETARGETDIR)
	$(call psExecuteCommand, \
    Invoke-WebRequest \
      -Uri ( ( Select-Xml -LiteralPath '$<' -XPath '/package/files/file[@fileid=\"$(call getExternalFileId,$*)\"]/@url').Node.Value ) \
      -OutFile $@ \
      -Verbose \
    ; \
  )
	@touch $@

%.$(FILEHASHALGORITHM):
	$(MAKETARGETDIR)
	$(call psExecuteCommand, \
    ( Get-FileHash -LiteralPath '$<' -Algorithm $(FILEHASHALGORITHM) -Verbose ).Hash \
    | Out-File -LiteralPath '$@' -Encoding utf8 -Force -Verbose \
    ; \
  )

#	checksum -t=$(FILEHASHALGORITHM) -f="$<" >> "$@"

# $(call getChocoPackageWebFileChecksumAux,externalFileXml,bitsPrefix)
define getChocoPackageWebFileChecksumAux

$(call getChocoPackageWebFileChecksumAuxFile,$1,$2) ?= $(CHOCO_PACKAGE_WEBFILES_AUXDIR)/$(call getExternalFileId,$1)$(2)
$$($(call getChocoPackageWebFileChecksumAuxFile,$1,$2)): $1

$(call getChocoPackageWebFileChecksumTarget,$1,$2) ?= $(dir $1)$(call getExternalFileId,$1)$(2).$(FILEHASHALGORITHM)
$$($(call getChocoPackageWebFileChecksumTarget,$1,$2)): $$($(call getChocoPackageWebFileChecksumAuxFile,$1,$2)) $1

endef

# $(call defineChocoPackageWebFile,id,packageId,externalFileXml)
define defineChocoPackageWebFile

$(call getChocoPackageWebFileChecksumAux,$3)

$$($(1)TARGETS): $$($(call getChocoPackageWebFileChecksumTarget,$3))

endef

# $(call calcChocoPackageFileName, packageId, packageVersion)
calcChocoPackageFileName = $1.$2.nupkg

# $(call packChocoPackageAux, id, packageId, installerArgs, packageVersion, preReleaseSuffix, dependencies)
define packChocoPackageAux

export $(1)TARGETS ?= $(OUTPUTDIR)/$2/$$($(1)VERSION)/$(call calcChocoPackageFileName,$2,$$($(1)VERSION))
$(call declareGlobalTargets,$(1)TARGETS)
$(1)NUSPEC      ?= $(wildcard $(SOURCESDIR)/$2/*.nuspec)
$(1)TOOLS       ?= $(wildcard $(SOURCESDIR)/$2/chocolatey*.ps1)
$(1)VERSION     ?= $4
$(1)VERSIONSUFFIX ?= $5

$$($(1)TARGETS): $$($(1)NUSPEC) $$($(1)TOOLS) $6
	$$(info Generate chocolatey package file "$$@"...)
	$$(MAKETARGETDIR)
	cd $$(@D) && $$(CHOCO) \
    pack $$(subst $$(SPACE),/,$$(patsubst %,..,$$(subst /,$$(SPACE),$$(@D))))/$$< \
    --force \
    --version $$($(1)VERSION) \
    --verbose
	@touch $$@

.PHONY: $1
$(1): $$($(1)TARGETS)

endef

# $(call packChocoMSIPackage, id, packageId, productCode, packageVersion, preReleaseSuffix, dependencies)
packChocoMSIPackage = $(call packChocoPackageAux,$1,$2,,$4,$5,$6)

# $(call packChocoWebPackage, id, packageId, packageVersion, preReleaseSuffix, dependencies)
packChocoWebPackage = $(call packChocoPackageAux,$1,$2,,$3,$4,$5)

# test's templates for package

# $(call defineInstallTestForChocoPackage,id,packageId)
define defineInstallTestForChocoPackage

$(call defineTest,install,$1,\
  $(CHOCO) install $2 --force --confirm -pre --source "$$(<D)", \
  $$($(1)TARGETS) \
)

endef

# $(call defineInstallWithPowerShellTestForChocoPackage,id,packageId)
define defineInstallWithPowerShellTestForChocoPackage

$(call defineTest,install_with_powershell,$1,\
  $(call psExecuteCommand,\
    Set-Variable -Name ErrorActionPreference -Value Stop; \
    Register-PackageSource -ProviderName Chocolatey -Name Test -Location '$$(call winPath,$$(abspath $$(<D)))' -Trusted -Verbose; \
    Install-Package -Name $2 -Source Test -Force -Verbose; \
    Unregister-PackageSource -Name Test -Verbose; \
  ), \
  $$($(1)TARGETS) \
)

endef

# $(call defineUninstallTestForChocoPackage,id,packageId)
define defineUninstallTestForChocoPackage

$(call defineTest,uninstall,$1,\
  $(CHOCO) uninstall $2 --confirm \
)

endef

# $(call defineUninstallWithPowerShellTestForChocoPackage,id,packageId)
define defineUninstallWithPowerShellTestForChocoPackage

$(call defineTest,uninstall_with_powershell,$1,\
  $(call psExecuteCommand,\
    Set-Variable -Name ErrorActionPreference -Value Stop; \
    Uninstall-Package -Name $2 -Verbose; \
  ) \
)

endef

endif