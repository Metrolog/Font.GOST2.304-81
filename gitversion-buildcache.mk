ifndef MAKE_GITVERSION_BUILDCACHE_DIR
MAKE_GITVERSION_BUILDCACHE_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(MAKE_GITVERSION_BUILDCACHE_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

GITVERSIONVARS := Major Minor Patch PreReleaseTag PreReleaseTagWithDash PreReleaseLabel PreReleaseNumber \
  BuildMetaData BuildMetaDataPadded FullBuildMetaData MajorMinorPatch SemVer LegacySemVer LegacySemVerPadded \
  AssemblySemVer FullSemVer InformationalVersion BranchName Sha \
  NuGetVersionV2 NuGetVersion \
  CommitsSinceVersionSource CommitsSinceVersionSourcePadded CommitDate

%/version.mk: $(REPOVERSION)
	$(file > $@,#version data file)
	$(foreach var,$(GITVERSIONVARS),$(file >> $@,export $(call setvariable,$(var),$(GitVersion_$(var)))))
	touch $@

endif