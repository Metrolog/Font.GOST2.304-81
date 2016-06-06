###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

.DEFAULT_GOAL		:= all


.PHONY: all
all: ttf ttc woff otf pstype0 pstype1 ctan msm msi

.SECONDARY:;

.SECONDEXPANSION:;

.DELETE_ON_ERROR:;

###

FONT               := GOST2.304-81TypeA
LATEXPKG           := gost2-304
SRCDIR             := sources
OUTPUTDIR          := release
AUXDIR             := obj
TOOLSDIR           := tools
TOOLSLIBS          := $(TOOLSDIR)/itgFontLib.py

# setup tools

include ITG.MakeUtils/common.mk
include ITG.MakeUtils/TeX/gitversion.mk

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

ifeq ($(VIEWPDF),yes)
	VIEWPDFOPT := -pv
else
	VIEWPDFOPT := -pv-
endif

TEXLUA             ?= texlua
PDFVIEWER          ?= start
LATEXMK            ?= latexmk \
	-xelatex \
	-auxdir=$(AUXDIR) \
	$(VIEWPDFOPT) \
	-e '$$pdf_previewer=q/$(PDFVIEWER) %O %S/' \
	-recorder -gg \
	-use-make \
	-interaction=nonstopmode \
	-halt-on-error

# generate aux .sfd files

FULLSTROKEDFONTSFD	:= $(AUXDIR)/$(FONT)-stroked-full-aux.sfd
FFBUILDSTROKEDSFD	:= $(TOOLSDIR)/build-stroked-sfd.py
FFBUILDSTROKEDSFDPRE:=

$(FULLSTROKEDFONTSFD): $(SRCDIR)/$(FONT).sfd $(SRCDIR)/$(FONT).fea $(FFBUILDSTROKEDSFD) $(FFBUILDSTROKEDSFDPRE) $(TOOLSLIBS)
	$(info Build additional glyphs, additional .sfd processing for stroked font...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSTROKEDSFD) $< $(<:.sfd=.fea) $@ $(FULLVERSION)

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

LASTSFDLABEL    := autokern
FONTVARIANTS		:= Regular Slanted
FONTALLSFD			:= $(foreach VARIANT, $(FONTVARIANTS), $(AUXDIR)/$(FONT)-$(VARIANT)-$(LASTSFDLABEL).sfd)

# $(call generateTargetFromSources, type, target, sources)
define generateTargetFromSources

FFGENERATE$(1)  ?= $(TOOLSDIR)/generate-$(1).py
$(1)DEPS        ?= $$(FFGENERATE$(1)) $(TOOLSLIBS)
$(1)TARGETS     ?= $2
$(1)SOURCES     ?= $3

$$($(1)TARGETS): $$($(1)SOURCES) $$($(1)DEPS)
	$$(info Generate $1 font file "$$@"...)
	$$(MAKETARGETDIR)
	$$(FONTFORGE) -script $$(FFGENERATE$(1)) $$@ $$(filter-out $$($(1)DEPS),$$^)

.PHONY: $1
$(1): $$($(1)TARGETS)

endef

# $(call generateFontsOfType, type, fileext, [sourceFileTemplate], [ расширения файлов-сателитов (без точек)] )
define generateFontsOfType

$(1)DIR         ?= $(OUTPUTDIR)/$(1)
FFGENERATE$(1)  ?= $(TOOLSDIR)/generate-$(1).py
$(1)DEPS        ?= $$(FFGENERATE$(1)) $(TOOLSLIBS)
$(1)EXT         ?= $2
$(1)MAINTARGETS := $(foreach VARIANT,$(FONTVARIANTS),$$($(1)DIR)/$(FONT)-$(VARIANT).$$($(1)EXT))
$(1)EXTS        ?= $4
$(1)TARGETS     := $$($(1)MAINTARGETS) $$(foreach ext,$$($(1)EXTS),$$($(1)MAINTARGETS:.$$($(1)EXT)=.$$(ext)))
ifneq ($(strip $3),)
  $(1)SOURCES   ?= $3
else
  $(1)SOURCES   ?= $(AUXDIR)/%-$(LASTSFDLABEL).sfd
endif

$$($(1)DIR)/%.$$($(1)EXT) $$(foreach ext,$$($(1)EXTS),$$($(1)DIR)/%.$$(ext)): $$($(1)SOURCES) $$($(1)DEPS)
	$$(info Generate .$2 font file "$$@"...)
	$$(MAKETARGETDIR)
	$$(FONTFORGE) -script $$(FFGENERATE$(1)) $$($(1)DIR)/$$*.$$($(1)EXT) $$(filter-out $$($(1)DEPS),$$^)

.PHONY: $1
$(1): $$($(1)TARGETS)

endef

# build True Type fonts

ttfDIR				:= $(OUTPUTDIR)/ttf
FFGENERATEttf		:= $(TOOLSDIR)/generate-ttf.py
ttfTARGETS			:= $(foreach VARIANT, $(FONTVARIANTS), $(ttfDIR)/$(FONT)-$(VARIANT).ttf)

ifeq ($(AUTOHINT),ttfautohint)

$(AUXDIR)/%-beforehinting.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATEttf) $(TOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATEttf) $@ $<

$(AUXDIR)/%.ttf: $(AUXDIR)/%-beforehinting.ttf
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@

else

ifeq ($(AUTOHINT),fontforge)
	FFGENERATEttf	:= $(TOOLSDIR)/generate-autohinted-ttf.py
endif

$(AUXDIR)/%.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATEttf) $(TOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) -script $(FFGENERATEttf) $@ $<

endif 

$(ttfDIR)/%.ttf: $(AUXDIR)/%.ttf
	#-$(FASTFONT) $<
	$(MAKETARGETDIR)
	cp $< $@

.PHONY: ttf
ttf: $(ttfTARGETS)

# build font files
$(eval $(call generateTargetFromSources,ttc,$(ttfDIR)/$(FONT).ttc,$(ttfTARGETS)))
$(eval $(call generateFontsOfType,woff,woff,$(ttfDIR)/%.ttf))
$(eval $(call generateFontsOfType,otf,otf,,afm))
$(eval $(call generateFontsOfType,pstype0,ps,,afm pfm tfm))
$(eval $(call generateFontsOfType,pstype1,pfb,,afm pfm tfm))

# latex build system

LATEXSRCDIR := latex
LATEXPKGMAINDIR := $(LATEXSRCDIR)/$(LATEXPKG)
LATEXPKGSOURCEFILESPATTERN := *.ins *.dtx
LATEXPKGSOURCEFILES := $(foreach PATTERN,$(LATEXPKGSOURCEFILESPATTERN),$(wildcard $(LATEXPKGMAINDIR)/$(PATTERN)))

# build latex version file

LATEXPRJVERSIONFILE := $(LATEXPKGMAINDIR)/version.dtx

# unpack latex package files

LATEXPKGUNPACKDIR := $(AUXDIR)/$(LATEXPKG)
LATEXPKGINSTALLFILES := $(LATEXPKGUNPACKDIR)/$(LATEXPKG).sty
LATEXUNPACK ?= latex \
	-interaction=nonstopmode \
	-platform windows:dpiawareness=0 \
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
LATEXPKGDOCS := $(AUXDIR)/$(LATEXPKG).rus.pdf
LATEXMKRC := $(LATEXSRCDIR)/latexmkrc

export TEXINPUTS = .$(PATHSEP)$(LATEXPKGMAINDIR)$(PATHSEP)$(LATEXTDSPKGPATH)$(PATHSEP)
export TEXFONTS = $(ttfDIR)

$(LATEXPKGTYPESETDIR)/%.pdf: $(LATEXPKGTYPESETDIR)/%.dtx $(LATEXPRJVERSIONFILE) $(LATEXSANDBOXSOURCEFILES) $(LATEXPKGINSTALLFILES) $(LATEXMKRC) $(ttfTARGETS)
	$(info Build package doc files "$@"...)
	$(MAKETARGETDIR)
	$(LATEXMK) -r $(LATEXMKRC) -outdir=$(@D) $<

$(eval $(call copyfile,$(LATEXPKGDOCS),$(LATEXPKGTYPESETDIR)/$(LATEXPKG).pdf))

.PHONY: doc
doc: $(LATEXPKGDOCS)

# build TDS and CTAN archives for CTAN

export CTAN_DIRECTORY := /fonts/$(LATEXPKG)
export LICENSE := free
export FREEVERSION := ofl
export NAME := Sergey S. Betke
export EMAIL := Sergey.S.Betke@yandex.ru

include ITG.MakeUtils/TeX/CTAN.mk

.CTAN: $(LATEXPKGINSTALLFILES) $(LATEXPKGSOURCEFILES)
.CTAN: $(LATEXPKGDOCS) $(wildcard $(LATEXPKGMAINDIR)/*.md)
.CTAN: $(ttfTARGETS) $(otfTARGETS) $(filter %.pfm %.tfm,$(pstype1TARGETS))

# msi module

.PHONY: msm
msm: $(ttfTARGETS)
	$(eval export DEPENDENCIES := $(foreach file,$(ttfTARGETS),../$(file)))
	$(MAKE) -C msm

# msi module

.PHONY: msi
msi: msm $(ttfTARGETS) $(otfTARGETS)
	$(eval export DEPENDENCIES := $(foreach file,$(ttfTARGETS) $(otfTARGETS),../$(file)))
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
