ifndef MAKE_NUGET_DIR
MAKE_NUGET_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

include $(realpath $(MAKE_NUGET_DIR)/common.mk)

NUGET ?= nuget

NUGET_PACKAGES_CONFIG  ?= packages.config
NUGET_PACKAGES_DIR     ?= packages

$(NUGET_PACKAGES_DIR)/%: ;
	$(info Expected package $@...)
	$(NUGET) \
    install $(NUGET_PACKAGES_CONFIG) \
    -OutputDirectory $(NUGET_PACKAGES_DIR) \
    -ExcludeVersion

clean::
	rm -rf $(NUGET_PACKAGES_DIR)

endif