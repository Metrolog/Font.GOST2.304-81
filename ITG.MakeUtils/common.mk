ifndef MAKE_COMMON_DIR
MAKE_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

AUXDIR             ?= obj

SPACE              := $(empty) $(empty)

MAKETARGETDIR      = /usr/bin/mkdir -p $(@D)
MAKETARGETASDIR    = /usr/bin/mkdir -p $@

ifeq ($(OS),Windows_NT)
	PATHSEP          :=;
else
	PATHSEP          :=:
endif

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

endif