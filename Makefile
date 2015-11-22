###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

.DEFAULT_GOAL		:= all


.PHONY: all
all: ttf ttc woff otf ps0 ctan tex-tests msm

.SECONDARY:;

.SECONDEXPANSION:;

.DELETE_ON_ERROR:;

###

FONT				:= GOST2.304-81TypeA
LATEXPKG			:= gost2.304
SPACE				:= $(empty) $(empty)
SRCDIR				:= sources
OUTPUTDIR			:= release
AUXDIR				:= obj
TOOLSDIR			:= tools
TOOLSLIBS			:= $(TOOLSDIR)/itgFontLib.py

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
	MKDIR			= "%ProgramFiles(x86)%/GnuWin32/bin/mkdir"
	FONTFORGE		?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
	PY				:= "%ProgramFiles(x86)%/FontForgeBuilds/bin/ffpython"
	TTFAUTOHINT		?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" $(TTFAUTOHINTOPTIONS)
	FASTFONT		?= "%ProgramFiles(x86)%/FontTools/fastfont"
	PATHSEP			:=;
else
	MKDIR			= mkdir
	FONTFORGE		?= fontforge
	PY				?= python
	TTFAUTOHINT		?= ttfautohint $(TTFAUTOHINTOPTIONS)
	FASTFONT		?= fastfont
	PATHSEP			:=:
endif

MAKETARGETDIR		= $(MKDIR) -p $(@D)

ifeq ($(VIEWPDF),yes)
	VIEWPDFOPT		:= -pv
else
	VIEWPDFOPT		:= -pv-
endif

TEXLUA				?= texlua
LATEXMK				?= latexmk \
	-xelatex \
	-auxdir=$(AUXDIR) \
	$(VIEWPDFOPT) \
	-recorder -gg \
	-use-make \
	-interaction=nonstopmode \
	-halt-on-error
ZIP					?= zip \
	-o \
	-9
TAR					?= tar

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

## grab a version number from the repository (if any) that stores this.
## * REVISION is the current revision number (short form, for inclusion in text)
## * VCSTURD is a file that gets touched after a repo update
REVISION			:= $(shell git rev-parse --short HEAD)
GIT_BRANCH			:= $(shell git symbolic-ref HEAD)
VCSTURD				:= $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
export VERSION		:= $(lastword $(subst /, ,$(GIT_BRANCH)))
export MAJORVERSION	:= $(firstword $(subst ., ,$(VERSION)))
export MINORVERSION	:= $(wordlist 2,2,$(subst ., ,$(VERSION)))

# generate aux .sfd files

FULLSTROKEDFONTSFD	:= $(AUXDIR)/$(FONT)-stroked-full-aux.sfd
FFBUILDSTROKEDSFD	:= $(TOOLSDIR)/build-stroked-sfd.py
FFBUILDSTROKEDSFDPRE:=

$(FULLSTROKEDFONTSFD): $(SRCDIR)/$(FONT).sfd $(SRCDIR)/$(FONT).fea $(FFBUILDSTROKEDSFD) $(FFBUILDSTROKEDSFDPRE) $(TOOLSLIBS)
	$(info Build additional glyphs, additional .sfd processing for stroked font...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSTROKEDSFD) $< $(<:.sfd=.fea) $@ $(VERSION)

# generate aux regular .sfd file

REGULARFONTSFD		:= $(AUXDIR)/$(FONT)-Regular.sfd
FFBUILDREGULARSFD	:= $(TOOLSDIR)/build-regular-sfd.py

#$(REGULARFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDREGULARSFD) $(TOOLSLIBS)
#	$(info Build stroked regular font .sfd file "$@"...)
#	$(MAKETARGETDIR)
#	$(PY) $(FFBUILDREGULARSFD) $< $@

$(eval $(call copyfile,$(REGULARFONTSFD),$(FULLSTROKEDFONTSFD)))

# generate aux slanted .sfd file

SLANTEDFONTSFD		:= $(AUXDIR)/$(FONT)-Slanted.sfd
FFBUILDSLANTEDSFD	:= $(TOOLSDIR)/build-slanted-sfd.py

$(SLANTEDFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDSLANTEDSFD) $(TOOLSLIBS)
	$(info Build stroked slanted font .sfd file "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSLANTEDSFD) $< $@

# stroke font -> outline font

FFEXPANDSTROKE	:= $(TOOLSDIR)/expand-stroke-sfd.py

$(AUXDIR)/%-outline.sfd: $(AUXDIR)/%.sfd $(FFEXPANDSTROKE) $(TOOLSLIBS)
	$(info Expand stroke font to outline font "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFEXPANDSTROKE) $< $@

# autokern outline font

FFAUTOKERN		:= $(TOOLSDIR)/autokern-classes-sfd.py

$(AUXDIR)/%-autokern.sfd: $(AUXDIR)/%-outline.sfd $(FFAUTOKERN) $(TOOLSLIBS)
	$(info Auto kerning outline font "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFAUTOKERN) $< $@

# all FontForge aux projects

FONTVARIANTS		:= Regular Slanted
FONTALLSFD			:= $(foreach VARIANT, $(FONTVARIANTS), $(AUXDIR)/$(FONT)-$(VARIANT)-autokern.sfd)

# build True Type fonts

TTFDIR				:= $(OUTPUTDIR)/ttf
FFGENERATETTF		:= $(TOOLSDIR)/generate-ttf.py
TTFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(TTFDIR)/$(FONT)-$(VARIANT).ttf)

ifeq ($(AUTOHINT),ttfautohint)

$(AUXDIR)/%.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATETTF) $(TOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATETTF) $< $@
	
$(TTFDIR)/%.ttf: $(AUXDIR)/%.ttf
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@
	$(FASTFONT) $@

else

ifeq ($(AUTOHINT),fontforge)
	FFGENERATETTF	:= $(TOOLSDIR)/generate-autohinted-ttf.py
endif

$(TTFDIR)/%.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATETTF) $(TOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATETTF) $< $@
	$(FASTFONT) $@

endif 

.PHONY: ttf
ttf: $(TTFTARGETS)

# build True Type collection

FFGENERATETTC		:= $(TOOLSDIR)/generate-ttc.py

$(TTFDIR)/$(FONT).ttc: $(TTFTARGETS) $(FFGENERATETTC) $(TOOLSLIBS)
	$(info Generate .ttc collection "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATETTC) $@ $(TTFTARGETS)

.PHONY: ttc
ttc: $(TTFDIR)/$(FONT).ttc ttf

# build Web Open Font Format

WOFFDIR				:= $(OUTPUTDIR)/woff
FFGENERATEWOFF		:= $(TOOLSDIR)/generate-woff.py
WOFFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(WOFFDIR)/$(FONT)-$(VARIANT).woff)

$(WOFFDIR)/%.woff: $(TTFDIR)/%.ttf $(FFGENERATEWOFF) $(TOOLSLIBS)
	$(info Generate .woff font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATEWOFF) $< $@

.PHONY: woff
woff: $(WOFFTARGETS)

# build Open Type fonts

OTFDIR				:= $(OUTPUTDIR)/otf
FFGENERATEOTF		:= $(TOOLSDIR)/generate-autohinted-otf.py
OTFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(OTFDIR)/$(FONT)-$(VARIANT).otf)

$(OTFDIR)/%.otf: $(AUXDIR)/%-autokern.sfd $(FFGENERATEOTF) $(TOOLSLIBS)
	$(info Generate .otf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATEOTF) $< $@

.PHONY: otf
otf: $(OTFTARGETS)

# build PS Type 0 fonts

PSDIR				:= $(OUTPUTDIR)/ps
PS0DIR				:= $(PSDIR)/ps0
FFGENERATEPS0		:= $(TOOLSDIR)/generate-ps0.py
PS0TARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(PS0DIR)/$(FONT)-$(VARIANT).ps)

$(PS0DIR)/%.ps: $(AUXDIR)/%-autokern.sfd $(FFGENERATEPS0) $(TOOLSLIBS)
	$(info Generate PS Type 0 font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) $(FONTFORGEOPTIONS) -script $(FFGENERATEPS0) $< $@

.PHONY: ps0
ps0: $(PS0TARGETS)

# latex build system

LATEXSRCDIR := latex
LATEXPKGMAINDIR := $(LATEXSRCDIR)/$(LATEXPKG)
LATEXPKGSOURCEFILESPATTERN := *.ins *.dtx
LATEXPKGSOURCEFILES := $(foreach PATTERN,$(LATEXPKGSOURCEFILESPATTERN),$(wildcard $(LATEXPKGMAINDIR)/$(PATTERN)))

# unpack latex package files

LATEXPKGUNPACKDIR := $(AUXDIR)/$(LATEXPKG)
LATEXPKGINSTALLFILES := $(LATEXPKGUNPACKDIR)/$(LATEXPKG).sty
LATEXUNPACK ?= latex \
	-interaction=nonstopmode \
	-halt-on-error

LATEXSANDBOXSOURCEFILES := $(patsubst $(LATEXPKGMAINDIR)/%,$(LATEXPKGUNPACKDIR)/%,$(LATEXPKGSOURCEFILES))
$(foreach file,$(LATEXSANDBOXSOURCEFILES),$(eval $(call copyfilefrom,$(file),$(LATEXPKGMAINDIR))))

$(LATEXPKGINSTALLFILES): $(LATEXSANDBOXSOURCEFILES)
	$(info Unpack [by docstrip] package files "$@"...)
	$(MAKETARGETDIR)
	cd $(<D) && $(LATEXUNPACK) $(<F)

.PHONY: unpack
unpack: $(LATEXPKGINSTALLFILES)

# Build package doc files

LATEXPKGTYPESETDIR := $(LATEXPKGUNPACKDIR)
LATEXPKGDOCS := $(LATEXPKGTYPESETDIR)/$(LATEXPKG).pdf
LATEXTYPESET ?= xelatex \
	-interaction=nonstopmode \
	-halt-on-error

$(LATEXPKGTYPESETDIR)/%.pdf: $(LATEXPKGTYPESETDIR)/%.dtx $(LATEXSANDBOXSOURCEFILES)
	$(info Build package doc files "$@"...)
	$(MAKETARGETDIR)
	$(LATEXMK) -outdir=$(@D) $<

.PHONY: doc
doc: $(LATEXPKGDOCS)

# build TDS archive for CTAN

LATEXTDSAUXDIR := $(AUXDIR)/tds

LATEXTDSPKGTARGETS := $(patsubst $(LATEXPKGUNPACKDIR)/%, $(LATEXTDSAUXDIR)/tex/latex/$(LATEXPKG)/%, $(LATEXPKGINSTALLFILES))
$(LATEXTDSPKGTARGETS): $$(patsubst $(LATEXTDSAUXDIR)/tex/latex/$(LATEXPKG)/%, $(LATEXPKGUNPACKDIR)/%, $$@)
	$(MAKETARGETDIR)
	cp $< $@

LATEXTDSFONTSTTFTARGETS := $(foreach FONTFILE, $(TTFTARGETS), $(LATEXTDSAUXDIR)/fonts/truetype/public/$(LATEXPKG)/$(notdir $(FONTFILE)))
$(foreach file,$(LATEXTDSFONTSTTFTARGETS),$(eval $(call copyfilefrom,$(file),$(TTFDIR))))

LATEXTDSFONTSOTFTARGETS := $(foreach FONTFILE, $(OTFTARGETS), $(LATEXTDSAUXDIR)/fonts/opentype/public/$(LATEXPKG)/$(notdir $(FONTFILE)))
$(foreach file,$(LATEXTDSFONTSOTFTARGETS),$(eval $(call copyfilefrom,$(file),$(OTFDIR))))

LATEXTDSDOCSTARGETS := $(foreach FILE,$(LATEXPKGDOCS),$(LATEXTDSAUXDIR)/doc/latex/$(LATEXPKG)/$(notdir $(FILE)))
$(foreach file,$(LATEXTDSDOCSTARGETS),$(eval $(call copyfilefrom,$(file),$(LATEXPKGTYPESETDIR))))

TDSFILES := $(LATEXTDSFONTSTTFTARGETS) $(LATEXTDSFONTSOTFTARGETS) $(LATEXTDSDOCSTARGETS) $(LATEXTDSPKGTARGETS)
TDSFILE := $(LATEXPKG).tds.zip
TDSTARGET := $(AUXDIR)/$(TDSFILE)
$(TDSTARGET): $(TDSFILES)
	$(MAKETARGETDIR)
	cd $(LATEXTDSAUXDIR) && $(ZIP) -FS -r -D $(abspath $@) $(patsubst $(LATEXTDSAUXDIR)/%, %, $^)

.PHONY: tds
tds: $(TDSTARGET)

# build dist package for CTAN

LATEXCTANAUXDIR := $(AUXDIR)/ctan
LATEXCTANTARGET := $(OUTPUTDIR)/ctan/$(LATEXPKG).tar.gz

$(LATEXCTANAUXDIR)/$(TDSFILE): $(TDSTARGET)
	$(MAKETARGETDIR)
	cp $< $@

$(LATEXCTANTARGET): $(LATEXCTANAUXDIR)/$(TDSFILE)
	$(MAKETARGETDIR)
	$(TAR) -c -C $(LATEXCTANAUXDIR) -f $@ $(patsubst $(LATEXCTANAUXDIR)/%, %, $^)

.PHONY: dist ctan
dist: $(LATEXCTANTARGET)
ctan: dist

# build latex tests

LATEXTESTSSRCDIR	:= $(LATEXSRCDIR)/tests
LATEXTESTSOUTPUTDIR := $(AUXDIR)
LATEXTESTSTARGETS	:= $(patsubst $(LATEXTESTSSRCDIR)/%.tex, $(LATEXTESTSOUTPUTDIR)/%.pdf, $(wildcard $(LATEXTESTSSRCDIR)/*.tex))

export TEXINPUTS=.$(PATHSEP)$(LATEXTDSAUXDIR)/tex/latex/$(LATEXPKG)/$(PATHSEP)
export TEXFONTS=$(LATEXTDSAUXDIR)/fonts/truetype/public/$(LATEXPKG)/$(PATHSEP)

$(LATEXTESTSOUTPUTDIR)/%.pdf: $(LATEXTESTSSRCDIR)/%.tex $(LATEXTDSPKGTARGETS) $(LATEXTDSFONTSTTFTARGETS)
	$(info Generate latex test pdf file "$@"...)
	$(LATEXMK) -outdir=$(@D) $<

.PHONY: tex-tests
tex-tests: $(LATEXTESTSTARGETS)

# msi module

msm: ttf
	$(MAKE) -C msm

# clean projects

.PHONY: clean
clean:
	$(info Erase aux and release directories...)
	rm -rf $(AUXDIR)
	rm -rf $(OUTPUTDIR)
	rm -rf $(LATEXPKGBUILDDIR)
	$(MAKE) -C msm clean

