ifndef MAKE_GITVERSION_BUILDCACHE_DIR
MAKE_GITVERSION_BUILDCACHE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(MAKE_GITVERSION_BUILDCACHE_DIR)common.mk

GITVERSIONVARS := Major Minor Patch PreReleaseTag PreReleaseTagWithDash PreReleaseLabel PreReleaseNumber \
  BuildMetaData BuildMetaDataPadded FullBuildMetaData MajorMinorPatch SemVer LegacySemVer LegacySemVerPadded \
  AssemblySemVer FullSemVer InformationalVersion BranchName Sha \
  NuGetVersionV2 NuGetVersion \
  CommitsSinceVersionSource CommitsSinceVersionSourcePadded CommitDate

%.mk:
	$(file > $@,#version data file)
	$(foreach var,$(GITVERSIONVARS),$(file >> $@,export $(call setvariable,$(var),$(GitVersion_$(var)))))

endif