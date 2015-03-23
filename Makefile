###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

.DEFAULT_GOAL		:= all

all: ttf ttc woff

.PHONY: all clean ttf ttc woff

.SECONDARY:;

.DELETE_ON_ERROR:;

###

FONT				?= GOST2.304-81TypeA

SPACE				= $(empty) $(empty)
SRCDIR				:= sources/
OUTPUTDIR			:= release
TTFDIR				:= $(OUTPUTDIR)/ttf
WOFFDIR				:= $(OUTPUTDIR)/woff
AUXDIR				:= obj
TOOLSDIR			:= tools/

# setup tools

# fontforge, ttfautohint or no
AUTOHINT			?= fontforge

FONTFORGEOPTIONS	:= \
	-nosplash

TTFAUTOHINTOPTIONS	:= \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--strong-stem-width="gGD" \
	--composites \
	--no-info

ifeq ($(OS),Windows_NT)
	RM				:= del /S/Q
	RMDIR			:= rmdir /S/Q
	MAKETARGETDIR	= $(foreach d,$(subst /, ,${@D}),@mkdir $d && @cd $d && ) @echo dir "${@D}" created... 
	MAKETARGETDIR2	= cd $(dir ${@D}) && mkdir $(notdir ${@D})
	TOUCH			= @echo . >
	FONTFORGE		?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
	PY				:= "%ProgramFiles(x86)%/FontForgeBuilds/bin/ffpython"
	TTFAUTOHINT		?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" $(TTFAUTOHINTOPTIONS)
else
	RM				:= rm
	RMDIR			:= rmdir
	MAKETARGETDIR	= mkdir -p ${@D}
	MAKETARGETDIR2	= MAKETARGETDIR
	TOUCH			= touch
	FONTFORGE		?= fontforge
	PY				?= python
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
$(WOFFDIR)/dirstate: $(OUTPUTDIR)/dirstate

# generate aux .sfd files

FULLSTROKEDFONTSFD	:= $(AUXDIR)/$(FONT)-stroked-full-aux.sfd
FFBUILDSTROKEDSFD	:= $(TOOLSDIR)build-stroked-sfd.py
FFBUILDSTROKEDSFDPRE:= $(foreach file, numero.fea, $(TOOLSDIR)$(file))

$(FULLSTROKEDFONTSFD): $(SRCDIR)$(FONT).sfd $(FFBUILDSTROKEDSFD) $(FFBUILDSTROKEDSFDPRE) $(AUXDIR)/dirstate
	$(info Build additional glyphs, additional .sfd processing for stroked font...)
	$(PY) $(FFBUILDSTROKEDSFD) $< $@ $(VERSION)

# generate aux regular .sfd file

REGULARFONTSFD		:= $(AUXDIR)/$(FONT)-Regular.sfd
FFBUILDREGULARSFD	:= $(TOOLSDIR)build-regular-sfd.py

$(REGULARFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDREGULARSFD) $(AUXDIR)/dirstate
	$(info Build stroked regular font .sfd file "$@"...)
	$(PY) $(FFBUILDREGULARSFD) $< $@

# generate aux slanted .sfd file

SLANTEDFONTSFD		:= $(AUXDIR)/$(FONT)-Slanted.sfd
FFBUILDSLANTEDSFD	:= $(TOOLSDIR)build-slanted-sfd.py

$(SLANTEDFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDSLANTEDSFD) $(AUXDIR)/dirstate
	$(info Build stroked slanted font .sfd file "$@"...)
	$(PY) $(FFBUILDSLANTEDSFD) $< $@

# stroke font -> outline font

FFEXPANDSTROKE	:= $(TOOLSDIR)expand-stroke-sfd.py

$(AUXDIR)/%-outline.sfd: $(AUXDIR)/%.sfd $(FFEXPANDSTROKE) $(AUXDIR)/dirstate
	$(info Expand stroke font to outline font "$@"...)
	$(PY) $(FFEXPANDSTROKE) $< $@

# all FontForge aux projects

FONTVARIANTS		:= Regular Slanted
FONTALLSFD			:= $(foreach VARIANT, $(FONTVARIANTS), $(AUXDIR)/$(FONT)-$(VARIANT)-outline.sfd)

# build True Type fonts

FFGENERATETTF		:= $(TOOLSDIR)generate-ttf.py

TTFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(TTFDIR)/$(FONT)-$(VARIANT).ttf)

ifeq ($(AUTOHINT),ttfautohint)

$(AUXDIR)/%.ttf: $(AUXDIR)/%-outline.sfd $(FFGENERATETTF) $(AUXDIR)/dirstate
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATETTF) $< $@
	
$(TTFDIR)/%.ttf: $(AUXDIR)/%.ttf $(TTFDIR)/dirstate
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(TTFAUTOHINT) $< $@

else

ifeq ($(AUTOHINT),fontforge)
FFGENERATETTF		:= $(TOOLSDIR)generate-autohinted-ttf.py
endif

$(TTFDIR)/%.ttf: $(AUXDIR)/%-outline.sfd $(FFGENERATETTF) $(TTFDIR)/dirstate
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATETTF) $< $@

endif 

ttf: $(TTFTARGETS)

# build True Type collection

FFGENERATETTC		:= $(TOOLSDIR)generate-ttc.py

$(TTFDIR)/$(FONT).ttc: $(TTFTARGETS) $(FFGENERATETTC) $(TTFDIR)/dirstate
	$(info Generate .ttc collection "$@"...)
	$(PY) $(FFGENERATETTC) $@ $(TTFTARGETS)

ttc: $(TTFDIR)/$(FONT).ttc ttf

# build Web Open Font Format

FFGENERATEWOFF		:= $(TOOLSDIR)generate-woff.py

WOFFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(WOFFDIR)/$(FONT)-$(VARIANT).woff)

$(WOFFDIR)/%.woff: $(TTFDIR)/%.ttf $(FFGENERATEWOFF) $(WOFFDIR)/dirstate
	$(info Generate .woff font "$@"...)
	$(PY) $(FFGENERATEWOFF) $< $@

woff: $(WOFFTARGETS)

# clean projects

clean:
	$(info Erase aux and release directories...)
	-$(RMDIR) $(AUXDIR)
	-$(RMDIR) $(OUTPUTDIR)
