ifndef MAKE_NUGET_DIR
MAKE_NUGET_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(MAKE_NUGET_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

NUGET ?= nuget
NUGET_PACKAGES_DIR ?= packages

$(NUGET_PACKAGES_DIR)/%: $(MAKEFILES)
	$(NUGET) \
    install $(firstword $(subst /,$(SPACE),$(patsubst $(NUGET_PACKAGES_DIR)/%,%,$@))) \
    -OutputDirectory $(call winPath,$(NUGET_PACKAGES_DIR)) \
    $(NUGET_PACKAGE_INSTALL_ARGS_$(firstword $(subst /,$(SPACE),$(patsubst $(NUGET_PACKAGES_DIR)/%,%,$@)))) \
    -ExcludeVersion

clean::
	rm -rf $(NUGET_PACKAGES_DIR)

endif