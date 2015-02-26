###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

FONTFORGEPROJECTS	:= $(wildcard *.sfd)

SPACE				= $(empty) $(empty)
FONTSDIR			:= fonts
TTFSUBDIR			:= ttf
TTFDIR				:= $(FONTSDIR)/$(TTFSUBDIR)/
TEMPDIR				:= obj
TTFTEMPDIR			:= $(TEMPDIR)/$(TTFSUBDIR)/

# setup tools

TTFAUTOHINTOPTIONS	:= \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility --composites \
	--no-info

ifeq ($(OS),Windows_NT)
	RM				:= del /S/Q
	RMDIR			:= rmdir /S/Q
	MAKETARGETDIR	= $(foreach d,$(subst /, ,${@D}),mkdir $d && cd $d && ) @echo dir "${@D}" created...
	FONTFORGE		?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
	TTFAUTOHINT		?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" $(TTFAUTOHINTOPTIONS)
else
	RM				:= rm
	RMDIR			:= rmdir
	MAKETARGETDIR	= mkdir -p ${@D}
	FONTFORGE		?= fontforge
	TTFAUTOHINT		?= ttfautohint $(TTFAUTOHINTOPTIONS)
endif

FFBUILDTTF			:= build-ttf.pe

## grab a version number from the repository (if any) that stores this.
## * REVISION is the current revision number (short form, for inclusion in text)
## * VCSTURD is a file that gets touched after a repo update
REVISION			:= $(shell git rev-parse --short HEAD)
GIT_BRANCH			:= $(shell git symbolic-ref HEAD)
VCSTURD				:= $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
VERSION				:= $(lastword $(subst /, ,$(GIT_BRANCH)))

###

.DEFAULT_GOAL		:= all

.PHONY: all clean ttf

all: ttf

# build True Type fonts

BUILDTTF			:= $(FONTFORGE) -script $(FFBUILDTTF)
TTFTARGETS			:= $(FONTFORGEPROJECTS:%.sfd=$(TTFDIR)%.ttf)

$(TTFTEMPDIR)%.ttf: %.sfd $(FFBUILDTTF)
	-$(MAKETARGETDIR)
	$(BUILDTTF) $< $@ $(VERSION)
	
$(TTFDIR)%.ttf: $(TTFTEMPDIR)%.ttf
	-$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@

ttf: $(TTFTARGETS)

# clean projects

clean:
	-$(RMDIR) $(TEMPDIR)
	-$(RMDIR) $(FONTSDIR)
