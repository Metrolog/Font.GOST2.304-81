###
### GNU make Makefile for build GOST 2.304-81 projects
###

.DEFAULT_GOAL		:= all

.PHONY: all
all: fonts ctan msm msi

###

LATEXPKG           := gost2-304
OUTPUTDIR          := release
AUXDIR             := obj

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/TeX/gitversion.mk

# sub projects

$(eval $(call useSubProject,fonts,fonts,ttf ttc woff otf pstype0 pstype1))
$(eval $(call useSubProject,msm,setup/msm))
$(eval $(call useSubProject,msi,setup/msi))

# setup tools

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

# clean projects

clean::
	rm -rf $(AUXDIR)
	rm -rf $(OUTPUTDIR)
