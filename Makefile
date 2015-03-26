###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

.DEFAULT_GOAL		:= all

all: ttf ttc woff otf tex-pkg tex-tests

.PHONY: all clean ttf ttc woff otf tex-pkg tex-tests

.SECONDARY:;

.DELETE_ON_ERROR:;

###

FONT				:= GOST2.304-81TypeA
SPACE				:= $(empty) $(empty)
SRCDIR				:= sources/
OUTPUTDIR			:= release
AUXDIR				:= obj
TOOLSDIR			:= tools/

# setup tools

# fontforge, ttfautohint or no
AUTOHINT			?= ttfautohint
VIEWPDF				?= no

FONTFORGEOPTIONS	:= \
	-nosplash

TTFAUTOHINTOPTIONS	:= \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--strong-stem-width="gGD" \
	--composites \
	--no-info

ifeq ($(OS),Windows_NT)
	MAKETARGETDIR	= cd $(dir ${@D}) && mkdir $(notdir ${@D})
	FONTFORGE		?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
	PY				:= "%ProgramFiles(x86)%/FontForgeBuilds/bin/ffpython"
	TTFAUTOHINT		?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" $(TTFAUTOHINTOPTIONS)
	PATHSEP			:=;
else
	MAKETARGETDIR	= mkdir -p ${@D}
	FONTFORGE		?= fontforge
	PY				?= python
	TTFAUTOHINT		?= ttfautohint $(TTFAUTOHINTOPTIONS)
	PATHSEP			:=:
endif
ifeq ($(VIEWPDF),yes)
	VIEWPDFOPT		:= -pv
else
	VIEWPDFOPT		:= -pv-
endif
LATEXMK				?= latexmk -xelatex -auxdir=$(AUXDIR) -pdf -dvi- -ps- $(VIEWPDFOPT) -recorder -gg
# -interaction=batchmode

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
	$(MAKETARGETDIR)
	@touch $@

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

TTFDIR				:= $(OUTPUTDIR)/ttf
FFGENERATETTF		:= $(TOOLSDIR)generate-ttf.py
TTFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(TTFDIR)/$(FONT)-$(VARIANT).ttf)

$(TTFDIR)/dirstate: $(OUTPUTDIR)/dirstate

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
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATETTC) $@ $(TTFTARGETS)

ttc: $(TTFDIR)/$(FONT).ttc ttf

# build Web Open Font Format

WOFFDIR				:= $(OUTPUTDIR)/woff
FFGENERATEWOFF		:= $(TOOLSDIR)generate-woff.py
WOFFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(WOFFDIR)/$(FONT)-$(VARIANT).woff)

$(WOFFDIR)/dirstate: $(OUTPUTDIR)/dirstate

$(WOFFDIR)/%.woff: $(TTFDIR)/%.ttf $(FFGENERATEWOFF) $(WOFFDIR)/dirstate
	$(info Generate .woff font "$@"...)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATEWOFF) $< $@

woff: $(WOFFTARGETS)

# build Open Type fonts

OTFDIR				:= $(OUTPUTDIR)/otf
FFGENERATEOTF		:= $(TOOLSDIR)generate-autohinted-otf.py
OTFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(OTFDIR)/$(FONT)-$(VARIANT).otf)

$(OTFDIR)/dirstate: $(OUTPUTDIR)/dirstate

$(OTFDIR)/%.otf: $(AUXDIR)/%-outline.sfd $(FFGENERATEOTF) $(OTFDIR)/dirstate
	$(info Generate .otf font "$@"...)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATEOTF) $< $@

otf: $(OTFTARGETS)

# build latex style gost2.304.sty

LATEXPKG			:= gost2.304
LATEXPKGDIR			:= $(OUTPUTDIR)/latexpkg/$(LATEXPKG)
LATEXSRCDIR			:= $(SRCDIR)latex
LATEXPKGSRCDIR		:= $(LATEXSRCDIR)/$(LATEXPKG)
LATEXFONTSDIR		:= $(LATEXPKGDIR)/fonts
LATEXPKGFONTS		:= $(patsubst $(TTFDIR)/%.ttf, $(LATEXFONTSDIR)/%.ttf, $(TTFTARGETS))
LATEXPKGPRE			:= $(LATEXPKGDIR)/$(LATEXPKG).sty $(LATEXPKGFONTS)

$(OUTPUTDIR)/latexpkg/dirstate: $(OUTPUTDIR)/dirstate
$(LATEXPKGDIR)/dirstate: $(OUTPUTDIR)/latexpkg/dirstate
$(LATEXFONTSDIR)/dirstate: $(LATEXPKGDIR)/dirstate

$(LATEXFONTSDIR)/%.ttf: $(TTFDIR)/%.ttf $(LATEXFONTSDIR)/dirstate
	cp $< $@

$(LATEXPKGDIR)/$(LATEXPKG).sty: $(LATEXPKGSRCDIR)/$(LATEXPKG).sty $(LATEXPKGDIR)/dirstate $(LATEXPKGFONTS)
	$(info Generate latex style package "$@"...)
	cp $< $@

export TEXINPUTS=".$(PATHSEP)$(LATEXPKGDIR)/$(PATHSEP)"
export TEXFONTS="$(LATEXFONTSDIR)/$(PATHSEP)"

tex-pkg: $(LATEXPKGPRE)

# build latex tests

LATEXPKG			:= gost2.304
LATEXPKGDIR			:= $(OUTPUTDIR)/latexpkg/$(LATEXPKG)
LATEXTESTSSRCDIR	:= $(LATEXSRCDIR)/tests
LATEXTESTSOUTPUTDIR := $(AUXDIR)
LATEXTESTSTARGETS	:= $(patsubst $(LATEXTESTSSRCDIR)/%.tex, $(LATEXTESTSOUTPUTDIR)/%.pdf, $(wildcard $(LATEXTESTSSRCDIR)/*.tex))

$(LATEXTESTSOUTPUTDIR)/%.pdf: $(LATEXTESTSSRCDIR)/%.tex $(LATEXPKGPRE)
	$(info Generate latex test pdf file "$@"...)
	$(LATEXMK) -outdir=$(@D) $<

tex-tests: $(LATEXTESTSTARGETS) tex-pkg 

# clean projects

clean:
	$(info Erase aux and release directories...)
	rm -rf $(AUXDIR)
	rm -rf $(OUTPUTDIR)
