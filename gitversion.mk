ifndef MAKE_GITVERSION_DIR
MAKE_GITVERSION_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(MAKE_GITVERSION_DIR)common.mk

GITVERSIONTOOL ?= gitversion.bat

GITVERSIONVARS := Major Minor Patch PreReleaseTag PreReleaseTagWithDash PreReleaseLabel PreReleaseNumber \
  BuildMetaData BuildMetaDataPadded FullBuildMetaData MajorMinorPatch SemVer LegacySemVer LegacySemVerPadded \
  AssemblySemVer FullSemVer InformationalVersion BranchName Sha \
  NuGetVersionV2 NuGetVersion \
  CommitsSinceVersionSource CommitsSinceVersionSourcePadded CommitDate

GITVERSIONMAKEFILE ?= version.mk
  
$(GITVERSIONMAKEFILE): .git/logs/HEAD
	$(info Generate version data file "$@" with GitVersion...)
	$(file > $@,#version data file)
	$(foreach var,$(GITVERSIONVARS),$(file >> $@,$(call setvariable,$(var),$(shell $(GITVERSIONTOOL) /showvariable $(var)))))
	$(info Version data file "$@" is ready for use.)

include $(GITVERSIONMAKEFILE)

GIT_BRANCH          := $(BranchName)
export VERSION      := $(Major).$(Minor)
export FULLVERSION  := $(SemVer)
export MAJORVERSION := $(Major)
export MINORVERSION := $(Minor)

endif