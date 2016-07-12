ifndef MAKE_COMMON_DIR
MAKE_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
export ITG_MAKEUTILS_DIR := $(realpath $(MAKE_COMMON_DIR))

.SECONDARY::;
.SECONDEXPANSION::;
.DELETE_ON_ERROR::;

AUXDIR             ?= obj

SPACE              := $(empty) $(empty)
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

# $(call calcRootProjectDir, ProjectDir)
calcRootProjectDir = $(subst $(SPACE),/,$(patsubst %,..,$(subst /,$(SPACE),$1)))

# $(call getSubProjectDir, Project)
getSubProjectDir = $($(1)_DIR)

# $(call setSubProjectDir, Project, ProjectDir)
define setSubProjectDir
export $(1)_DIR := $2
endef

MAKE_SUBPROJECT = $(MAKE) -C $(call getSubProjectDir,$1) ROOT_PROJECT_DIR=$(call calcRootProjectDir,$(call getSubProjectDir,$1))

# $(call declareProjectDeps, Project)
define declareProjectDeps
$(call getSubProjectDir,$1)/%:
	$(call MAKE_SUBPROJECT,$1) $$*
endef

# $(call useSubProjectWithTargets, SubProject, SubProjectDir, Targets)
define useSubProjectWithTargets
$(eval $(call setSubProjectDir,$1,$2))
$(call declareProjectDeps,$1)
.PHONY: $3
$3:
	$(call MAKE_SUBPROJECT,$1) $$@
clean::
	$(call MAKE_SUBPROJECT,$1) clean
endef

# $(call useSubProject, SubProject, SubProjectDir)
useSubProject = $(call useSubProjectWithTargets,$1,$2,$1)

ifdef ROOT_PROJECT_DIR
$(ROOT_PROJECT_DIR)/%:
	$(MAKE) -C $(ROOT_PROJECT_DIR) $*

endif


.PHONY: clean
clean::
	$(info Erase aux and release directories...)

endif