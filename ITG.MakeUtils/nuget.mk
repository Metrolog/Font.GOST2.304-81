ifndef MAKE_NUGET_DIR
MAKE_NUGET_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(MAKE_NUGET_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

NUGET ?= nuget

NUGET_PACKAGES_CONFIG  ?= packages.config
NUGET_PACKAGES_DIR     ?= packages

# $(call defineNugetPackagesConfig,ConfigFile,PackagesDir)
define defineNugetPackagesConfig

$(2)/%: $(1)
	$(NUGET) \
    install $$(call winPath,$$<) \
    -OutputDirectory $$(call winPath,$(2)) \
    -ExcludeVersion

clean::
	rm -rf $(2)

endef

$(eval $(call defineNugetPackagesConfig,$(NUGET_PACKAGES_CONFIG),$(NUGET_PACKAGES_DIR)))

endif