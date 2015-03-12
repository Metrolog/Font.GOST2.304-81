###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

FONT				?= GOST2.304-81TypeA

SPACE				= $(empty) $(empty)
SRCDIR				:= sources/
OUTPUTDIR			:= release
TTFDIR				:= $(OUTPUTDIR)/ttf
AUXDIR				:= obj
TOOLSDIR			:= tools/

# setup tools

TTFAUTOHINTOPTIONS	:= \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--composites \
	--no-info

ifeq ($(OS),Windows_NT)
	RM				:= del /S/Q
	RMDIR			:= rmdir /S/Q
	MAKETARGETDIR	= $(foreach d,$(subst /, ,${@D}),@mkdir $d && @cd $d && ) @echo dir "${@D}" created... 
	MAKETARGETDIR2	= cd $(dir ${@D}) && mkdir $(notdir ${@D})
	TOUCH			= @echo . >
	FONTFORGE		?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
	TTFAUTOHINT		?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" $(TTFAUTOHINTOPTIONS)
else
	RM				:= rm
	RMDIR			:= rmdir
	MAKETARGETDIR	= mkdir -p ${@D}
	MAKETARGETDIR2	= MAKETARGETDIR
	TOUCH			= touch
	FONTFORGE		?= fontforge
	TTFAUTOHINT		?= ttfautohint $(TTFAUTOHINTOPTIONS)
endif

## grab a version number from the repository (if any) that stores this.
## * REVISION is the current revision number (short form, for inclusion in text)
## * VCSTURD is a file that gets touched after a repo update
REVISION			:= $(shell git rev-parse --short HEAD)
GIT_BRANCH			:= $(shell git symbolic-ref HEAD)
VCSTURD				:= $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
VERSION				:= $(lastword $(subst /, ,$(GIT_BRANCH)))

# directories rules

dirstate:;

%/dirstate:
	$(info Directory "${@D}" creating...)
	$(MAKETARGETDIR2)
	@$(TOUCH) $@

$(TTFDIR)/dirstate: $(OUTPUTDIR)/dirstate

###

.DEFAULT_GOAL		:= all

.PHONY: all clean ttf

all: ttf

# generate aux .sfd files

FFBUILDREGULARSFD	:= $(TOOLSDIR)build-regular-sfd.pe

$(AUXDIR)/$(FONT)-Regular.sfd: $(SRCDIR)$(FONT).sfd $(FFBUILDREGULARSFD) $(AUXDIR)/dirstate
	$(info Build additional glyphs, additional .sfd processing...)
	$(FONTFORGE) -script $(FFBUILDREGULARSFD) $< $@ $(VERSION)

# build True Type fonts

FFGENERATETTF		:= $(TOOLSDIR)generate-ttf.pe

TTFTARGETS			:= $(TTFDIR)/$(FONT)-Regular.ttf
TTFNOAUTOHINTTARGETS:= $(TTFTARGETS:$(TTFDIR)/%.ttf=$(AUXDIR)/%.ttf)

$(AUXDIR)/%.ttf: $(AUXDIR)/%.sfd $(FFGENERATETTF)
	$(info Generate .ttf fonts...)
	$(FONTFORGE) -script $(FFGENERATETTF) $< $@
	
$(TTFDIR)/%.ttf: $(AUXDIR)/%.ttf $(TTFDIR)/dirstate
	$(info Autohinting and autoinstructing .ttf fonts (by ttfautohint)...)
	$(TTFAUTOHINT) $< $@

ttf: $(TTFTARGETS)

# clean projects

clean:
	$(info Erase aux and release directories...)
	-$(RMDIR) $(AUXDIR)
	-$(RMDIR) $(OUTPUTDIR)
