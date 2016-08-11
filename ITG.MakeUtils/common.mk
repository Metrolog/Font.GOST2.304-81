ifndef MAKE_COMMON_DIR
MAKE_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
export ITG_MAKEUTILS_DIR := $(realpath $(MAKE_COMMON_DIR))

.SECONDARY::;
.SECONDEXPANSION::;
.DELETE_ON_ERROR::;

.DEFAULT_GOAL      := all
.PHONY: all
.PHONY: test

AUXDIR             ?= obj
OUTPUTDIR          ?= release
SOURCESDIR         ?= sources
export REPOROOT    ?= $(abspath ./$(ROOT_PROJECT_DIR))/
REPOVERSION        = $(REPOROOT).git/logs/HEAD

SPACE              := $(empty) $(empty)
COMMA              :=,
LEFT_BRACKET       :=(
RIGHT_BRACKET      :=)
DOLLAR_SIGN        :=$$
ifeq ($(OS),Windows_NT)
	PATHSEP          :=;
else
	PATHSEP          :=:
endif

MAKETARGETDIR      = /usr/bin/mkdir -p $(@D)
MAKETARGETASDIR    = /usr/bin/mkdir -p $@

ZIP                ?= zip \
	-o \
	-9
TAR                ?= tar

# $(call setvariable, var, value)
define setvariable
$1:=$2

endef

# $(call copyfile, to, from)
define copyfile
$1: $2
	$$(MAKETARGETDIR)
	cp $$< $$@
endef

# $(call copyfileto, todir, fromfile)
copyfileto = $(call copyfile,$1/$(notdir $2),$2)

# $(call copyfilefrom, tofile, fromdir)
copyfilefrom = $(call copyfile,$1,$2/$(notdir $1))

# $(call copyFilesToZIP, targetZIP, sourceFiles, sourceFilesRootDir)
define copyFilesToZIP
$1:$2
	$$(MAKETARGETDIR)
	cd $3 && $(ZIP) -FS -o -r -D $$(abspath $$@) $$(patsubst $3/%, %, $$^)
	@touch $$@
endef

# $(call winPath,sourcePathOrFileName)
winPath = $(shell cygpath -w $1)

# $(call shellPath,sourcePathOrFileName)
shellPath = $(shell cygpath -u $1)

# $(call psExecuteCommand,powershellScriptBlock)
psExecuteCommand = \
  powershell \
    -NoLogo \
    -NonInteractive \
    -NoProfile \
    -ExecutionPolicy unrestricted \
    -Command "\
      Set-Variable -Name ErrorActionPreference -Value Stop; \
      & { $(1) }"

#
# subprojects
#

SUBPROJECTS_EXPORTS_DIR := $(AUXDIR)/subprojectExports
SUBPROJECT_EXPORTS_FILE ?= $(SUBPROJECTS_EXPORTS_DIR)/undefined

.PHONY: .GLOBAL_VARIABLES
.GLOBAL_VARIABLES: $(SUBPROJECT_EXPORTS_FILE)
$(SUBPROJECT_EXPORTS_FILE):: $(MAKEFILE_LIST)
	$(file > $@,# subproject exported variables)

# $(call exportGlobalVariablesAux, Variables, Writer)
define exportGlobalVariablesAux
$(SUBPROJECT_EXPORTS_FILE)::
	$(foreach var,$(1),$$(file >> $$@,export $(var)=$(call $(2),$(var))))

endef

# $(call exportGlobalVariables, Variables)
SimpleVariableWriter = $$($(1))
exportGlobalVariables = $(call exportGlobalVariablesAux,$(1),SimpleVariableWriter)
exportGlobalVariable = $(exportGlobalVariables)

# $(call pushArtifactTargets, Variables)
TargetWriter = $$(foreach path,$$($(1)),$$$$$$$$(ROOT_PROJECT_DIR)/$(SUBPROJECT_DIR)$$(path))
pushArtifactTargets = $(call exportGlobalVariablesAux,$(1),TargetWriter)
pushArtifactTarget = $(pushArtifactTargets)

# $(call calcRootProjectDir, Project)
calcRootProjectDir = $(subst $(SPACE),/,$(patsubst %,..,$(subst /,$(SPACE),$(call getSubProjectDir,$1))))

# $(call getSubProjectDir, Project)
getSubProjectDir = $($(1)_DIR)

# $(call setSubProjectDir, Project, ProjectDir)
define setSubProjectDir
export $(1)_DIR := $2
endef

# $(call MAKE_SUBPROJECT, Project)
MAKE_SUBPROJECT = $(MAKE) -C $(call getSubProjectDir,$1) \
  SUBPROJECT=$1 \
  SUBPROJECT_DIR=$(call getSubProjectDir,$1)/ \
  ROOT_PROJECT_DIR=$(call calcRootProjectDir,$1) \
  SUBPROJECT_EXPORTS_FILE=$(call calcRootProjectDir,$1)/$(SUBPROJECTS_EXPORTS_DIR)/$1.mk

# $(call declareProjectTargets, Project)
define declareProjectTargets
$(call getSubProjectDir,$1)/%:
	$(call MAKE_SUBPROJECT,$1) $$*
endef

# $(call useSubProject, SubProject, SubProjectDir [, Targets ])
define useSubProject
$(eval $(call setSubProjectDir,$1,$2))
$(SUBPROJECTS_EXPORTS_DIR)/$1.mk: $(call getSubProjectDir,$1)/Makefile
	$$(MAKETARGETDIR)
	$(call MAKE_SUBPROJECT,$1) .GLOBAL_VARIABLES
.PHONY: $1 $3
ifeq ($(filter clean,$(MAKECMDGOALS)),)
include $(SUBPROJECTS_EXPORTS_DIR)/$1.mk
endif
$1:
	$(call MAKE_SUBPROJECT,$1)
test-$1:
	$(call MAKE_SUBPROJECT,$1) --keep-going test
$3:
	$(call MAKE_SUBPROJECT,$1) $$@
$(foreach target,$3,test-$(target)):
	$(call MAKE_SUBPROJECT,$1) --keep-going $$@
$(foreach target,$3,test.%-$(target)):
	$(call MAKE_SUBPROJECT,$1) --keep-going $$@
$(call getSubProjectDir,$1)/%:
	$(call MAKE_SUBPROJECT,$1) $$*
all:: $1
test: test-$1
clean::
	@$(call MAKE_SUBPROJECT,$1) clean
endef

ifdef ROOT_PROJECT_DIR
$(ROOT_PROJECT_DIR)/%:
	$(MAKE) -C $(ROOT_PROJECT_DIR) $*

endif

.PHONY: test
test:

.PHONY: clean
clean::
	rm -rf $(AUXDIR)
	rm -rf $(OUTPUTDIR)

endif