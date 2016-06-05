ifndef MAKE_GITVERSION_DIR
MAKE_GITVERSION_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(MAKE_GITVERSION_DIR)common.mk

GITVERSIONTOOL ?= gitversion

GITVERSIONMAKEFILE ?= $(AUXDIR)/version.mk

$(dir $(GITVERSIONMAKEFILE)):
	$(MAKETARGETASDIR)

$(GITVERSIONMAKEFILE): .git/logs/HEAD | $(dir $(GITVERSIONMAKEFILE))
	$(info Generate version data file "$@" with GitVersion...)
	$(GITVERSIONTOOL) /exec $(MAKE) /execargs "--makefile=$(MAKE_GITVERSION_DIR)gitversion-buildcache.mk $@"

include $(GITVERSIONMAKEFILE)

GIT_BRANCH          := $(BranchName)
export VERSION      := $(Major).$(Minor)
export FULLVERSION  := $(SemVer)
export MAJORVERSION := $(Major)
export MINORVERSION := $(Minor)

endif