###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

.DEFAULT_GOAL		:= all


.PHONY: all
all: ttf ttc woff otf ps0 ctan tex-tests msm msi

.SECONDARY:;

.SECONDEXPANSION:;

.DELETE_ON_ERROR:;

###

FONT               := GOST2.304-81TypeA
LATEXPKG           := gost2-304
SPACE              := $(empty) $(empty)
SRCDIR             := sources
OUTPUTDIR          := release
AUXDIR             := obj
TOOLSDIR           := tools
TOOLSLIBS          := $(TOOLSDIR)/itgFontLib.py

# setup tools

MAKETARGETDIR      = /usr/bin/mkdir -p $(@D)
# fontforge, ttfautohint or no
AUTOHINT           ?= ttfautohint
VIEWPDF            ?= no
FONTFORGE          ?= fontforge \
	-nosplash
PY                 ?= ffpython
TTFAUTOHINT        ?= ttfautohint \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--composites \
	--strong-stem-width="gGD" \
	--no-info
#	FASTFONT         ?= fastfont

ifeq ($(OS),Windows_NT)
	PATHSEP          :=;
else
	PATHSEP          :=:
endif

ifeq ($(VIEWPDF),yes)
	VIEWPDFOPT := -pv
else
	VIEWPDFOPT := -pv-
endif

TEXLUA             ?= texlua
PDFVIEWER          ?= acroread
LATEXMK            ?= latexmk \
	-xelatex \
	-auxdir=$(AUXDIR) \
	$(VIEWPDFOPT) \
	-e '$$pdf_previewer=q/\"$(PDFVIEWER)\" %O %S/' \
	-recorder -gg \
	-use-make \
	-interaction=nonstopmode \
	-halt-on-error
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

# check git version
GITVERSION := $(lastword $(shell git --version))

## grab a version number from the repository (if any) that stores this.
## * VCSTURD is a file that gets touched after a repo update
GIT_BRANCH          := $(shell git symbolic-ref HEAD)
VCSTURD             := $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
export VERSION      := $(shell git symbolic-ref --short HEAD)
export FULLVERSION  := $(VERSION).$(shell git rev-list --count --first-parent HEAD).$(shell git rev-list --count HEAD)
export MAJORVERSION := $(firstword $(subst ., ,$(VERSION)))
export MINORVERSION := $(wordlist 2,2,$(subst ., ,$(VERSION)))

# build latex version file

LATEXPRJVERSIONFILE := $(AUXDIR)/version.tex

$(LATEXPRJVERSIONFILE): .git/logs/HEAD Makefile
	$(info Generate latex version file "$@"...)
	$(MAKETARGETDIR)
	@git log -1 --date=format:%Y/%m/%d --format="format:\
%%\iffalse%n\
%%<*version>%n\
%%\fi%n\
\def\GITCommitterName{%cn}%n\
\def\GITCommitterEmail{%ce}%n\
\def\GITCommitterDate{%cd}%n\
\def\ExplFileDate{%ad}%n\
\def\ExplFileVersion{$(FULLVERSION)}%n\
\def\ExplFileAuthor{%an}%n\
\def\ExplFileAuthorEmail{%ae}%n\
%%\iffalse%n\
%%</version>%n\
%%\fi%n\
" > $@

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

$(AUXDIR)/%-beforehinting.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATETTF) $(TOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATETTF) $< $@

$(AUXDIR)/%.ttf: $(AUXDIR)/%-beforehinting.ttf
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@

else

ifeq ($(AUTOHINT),fontforge)
	FFGENERATETTF	:= $(TOOLSDIR)/generate-autohinted-ttf.py
endif

$(AUXDIR)/%.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATETTF) $(TOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) -script $(FFGENERATETTF) $< $@

endif 

$(TTFDIR)/%.ttf: $(AUXDIR)/%.ttf
	#-$(FASTFONT) $<
	$(MAKETARGETDIR)
	cp $< $@

.PHONY: ttf
ttf: $(TTFTARGETS)

# build True Type collection

FFGENERATETTC		:= $(TOOLSDIR)/generate-ttc.py

$(TTFDIR)/$(FONT).ttc: $(TTFTARGETS) $(FFGENERATETTC) $(TOOLSLIBS)
	$(info Generate .ttc collection "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATETTC) $@ $(TTFTARGETS)

.PHONY: ttc
ttc: $(TTFDIR)/$(FONT).ttc ttf

# build Web Open Font Format

WOFFDIR				:= $(OUTPUTDIR)/woff
FFGENERATEWOFF		:= $(TOOLSDIR)/generate-woff.py
WOFFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(WOFFDIR)/$(FONT)-$(VARIANT).woff)

$(WOFFDIR)/%.woff: $(TTFDIR)/%.ttf $(FFGENERATEWOFF) $(TOOLSLIBS)
	$(info Generate .woff font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATEWOFF) $< $@

.PHONY: woff
woff: $(WOFFTARGETS)

# build Open Type fonts

OTFDIR				:= $(OUTPUTDIR)/otf
FFGENERATEOTF		:= $(TOOLSDIR)/generate-autohinted-otf.py
OTFTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(OTFDIR)/$(FONT)-$(VARIANT).otf)

$(OTFDIR)/%.otf: $(AUXDIR)/%-autokern.sfd $(FFGENERATEOTF) $(TOOLSLIBS)
	$(info Generate .otf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATEOTF) $< $@

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
	$(FONTFORGE) -script $(FFGENERATEPS0) $< $@

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

$(LATEXPKGINSTALLFILES): $(LATEXSANDBOXSOURCEFILES) $(LATEXPRJVERSIONFILE)
	$(info Unpack [by docstrip] package files "$@"...)
	$(MAKETARGETDIR)
	cd $(<D) && $(LATEXUNPACK) $(<F)

.PHONY: unpack
unpack: $(LATEXPKGINSTALLFILES)

# Build package doc files

LATEXPKGTYPESETDIR := $(LATEXPKGUNPACKDIR)
LATEXPKGDOCS := $(LATEXPKGTYPESETDIR)/$(LATEXPKG).pdf
LATEXMKRC := $(LATEXSRCDIR)/latexmkrc

$(LATEXPKGTYPESETDIR)/%.pdf: $(LATEXPKGTYPESETDIR)/%.dtx $(LATEXPRJVERSIONFILE) $(LATEXSANDBOXSOURCEFILES) $(LATEXPKGINSTALLFILES) $(LATEXMKRC) $(TTFTARGETS)
	$(info Build package doc files "$@"...)
	$(MAKETARGETDIR)
	$(LATEXMK) -r $(LATEXMKRC) -outdir=$(@D) $<

.PHONY: doc
doc: $(LATEXPKGDOCS)

# build TDS archive for CTAN

LATEXTDSAUXDIR := $(AUXDIR)/tds

LATEXTDSPKGPATH := $(LATEXTDSAUXDIR)/tex/latex/$(LATEXPKG)
LATEXTDSPKGTARGETS := $(patsubst $(LATEXPKGUNPACKDIR)/%, $(LATEXTDSPKGPATH)/%, $(LATEXPKGINSTALLFILES))
$(foreach file,$(LATEXTDSPKGTARGETS),$(eval $(call copyfilefrom,$(file),$(LATEXPKGUNPACKDIR))))

LATEXTDSFONTSTTFPATH = $(LATEXTDSAUXDIR)/fonts/truetype/public/$(LATEXPKG)
LATEXTDSFONTSTTFTARGETS := $(foreach FONTFILE, $(TTFTARGETS), $(LATEXTDSFONTSTTFPATH)/$(notdir $(FONTFILE)))
$(foreach file,$(LATEXTDSFONTSTTFTARGETS),$(eval $(call copyfilefrom,$(file),$(TTFDIR))))

LATEXTDSFONTSOTFPATH = $(LATEXTDSAUXDIR)/fonts/truetype/public/$(LATEXPKG)
LATEXTDSFONTSOTFTARGETS := $(foreach FONTFILE, $(OTFTARGETS), $(LATEXTDSFONTSOTFPATH)/$(notdir $(FONTFILE)))
$(foreach file,$(LATEXTDSFONTSOTFTARGETS),$(eval $(call copyfilefrom,$(file),$(OTFDIR))))

LATEXTDSDOCSTARGETS := $(foreach FILE,$(LATEXPKGDOCS),$(LATEXTDSAUXDIR)/doc/latex/$(LATEXPKG)/$(notdir $(FILE)))
$(foreach file,$(LATEXTDSDOCSTARGETS),$(eval $(call copyfilefrom,$(file),$(LATEXPKGTYPESETDIR))))

export TEXINPUTS = .$(PATHSEP)$(LATEXTDSPKGPATH)$(PATHSEP)
export TEXFONTS = $(LATEXTDSFONTSTTFPATH)

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

$(LATEXTESTSOUTPUTDIR)/%.pdf: $(LATEXTESTSSRCDIR)/%.tex $(LATEXTDSPKGTARGETS) $(LATEXTDSFONTSTTFTARGETS)
	$(info Generate latex test pdf file "$@"...)
	$(LATEXMK) -outdir=$(@D) $<

.PHONY: tex-tests
tex-tests: $(LATEXTESTSTARGETS)

# msi module

.PHONY: msm
msm: ttf
	$(MAKE) -C msm

# msi module

.PHONY: msi
msi: msm ttf otf
	$(MAKE) -C msi

# clean projects

.PHONY: clean
clean:
	$(info Erase aux and release directories...)
	rm -rf $(AUXDIR)
	rm -rf $(OUTPUTDIR)
	rm -rf $(LATEXPKGBUILDDIR)
	$(MAKE) -C msm clean
	$(MAKE) -C msi clean
