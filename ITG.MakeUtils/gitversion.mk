ifndef MAKE_GITVERSION_DIR
MAKE_GITVERSION_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

include $(realpath $(MAKE_GITVERSION_DIR)/common.mk)

GITVERSION ?= gitversion.bat

export GITVERSIONMAKEFILE ?= $(abspath $(AUXDIR)/version.mk)

$(dir $(GITVERSIONMAKEFILE)):
	$(MAKETARGETASDIR)

$(GITVERSIONMAKEFILE): .git/logs/HEAD | $(dir $(GITVERSIONMAKEFILE))
	$(info Generate version data file "$@" with GitVersion...)
	$(GITVERSION) /exec $(MAKE) /execargs "--makefile=$(MAKE_GITVERSION_DIR)/gitversion-buildcache.mk $@"

ifeq ($(filter clean,$(MAKECMDGOALS)),)
include $(GITVERSIONMAKEFILE)
endif

GIT_BRANCH          := $(BranchName)
export VERSION      := $(Major).$(Minor)
export FULLVERSION  := $(SemVer)
export MAJORVERSION := $(Major)
export MINORVERSION := $(Minor)

endif