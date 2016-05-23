ifndef MAKE_COMMON_DIR
MAKE_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

MAKETARGETDIR      = /usr/bin/mkdir -p $(@D)

ifeq ($(OS),Windows_NT)
	PATHSEP          :=;
else
	PATHSEP          :=:
endif

ZIP                ?= zip \
	-o \
	-9
TAR                ?= tar

# $(call copyfile, to, from)
define copyfile
$1: $2
	$$(MAKETARGETDIR)
	cp $$< $$@
endef

# $(call copyfileto, todir, fromfile)
copyfileto := $(call copyfile,$1/$(notdir $2),$2)

# $(call copyfilefrom, tofile, fromdir)
copyfilefrom = $(call copyfile,$1,$2/$(notdir $1))

endif