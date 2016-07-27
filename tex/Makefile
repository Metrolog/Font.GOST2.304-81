###
### GNU make Makefile for build GOST 2.304-81 tex package
###

all: ctan

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/TeX/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

# tools

ifeq ($(VIEWPDF),yes)
	VIEWPDFOPT := -pv -e '$$pdf_previewer=q/$(PDFVIEWER) %O %S/'
else
	VIEWPDFOPT := -pv-
endif

TEXLUA             ?= texlua
PDFVIEWER          ?= start
LATEXMK            ?= latexmk
LATEXMAKE          ?= $(LATEXMK) \
	-xelatex \
	-auxdir=$(AUXDIR) \
	$(VIEWPDFOPT) \
	-recorder -gg \
	-use-make \
	-interaction=nonstopmode \
	-halt-on-error
LATEXUNPACK        ?= latex \
	-interaction=nonstopmode \
	-halt-on-error

# latex build system

LATEXPKG := gost2-304
LATEXSRCDIR := sources
LATEXTOOLSDIR := tools
LATEXPKGMAINDIR := $(LATEXSRCDIR)/$(LATEXPKG)
LATEXPKGOTHERSOURCEFILESPATTERN := 
LATEXPRJVERSIONFILE := $(LATEXPKGMAINDIR)/version.dtx
LATEXPKGSOURCEFILES := \
  $(wildcard $(LATEXPKGMAINDIR)/*.ins) \
  $(sort $(wildcard $(LATEXPKGMAINDIR)/*.dtx) $(LATEXPRJVERSIONFILE)) \
  $(foreach PATTERN,$(LATEXPKGOTHERSOURCEFILESPATTERN),$(wildcard $(LATEXPKGMAINDIR)/$(PATTERN)))

# unpack latex package files

LATEXPKGUNPACKDIR := $(AUXDIR)/$(LATEXPKG)
LATEXPKGINSTALLFILES := $(LATEXPKGUNPACKDIR)/$(LATEXPKG).sty

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
LATEXMKRC := $(LATEXTOOLSDIR)/latexmkrc

export TEXINPUTS = .$(PATHSEP)$(LATEXPKGMAINDIR)$(PATHSEP)$(LATEXTDSPKGPATH)$(PATHSEP)
export TEXFONTS = $(ttfDIR)

$(LATEXPKGTYPESETDIR)/%.pdf: $(LATEXPKGTYPESETDIR)/%.dtx $(LATEXPRJVERSIONFILE) $(LATEXSANDBOXSOURCEFILES) $(LATEXPKGINSTALLFILES) $(LATEXMKRC) $(ttfTARGETS)
	$(info Build package doc files "$@"...)
	$(MAKETARGETDIR)
	$(LATEXMAKE) -r $(LATEXMKRC) -outdir=$(@D) $<

$(eval $(call copyfile,$(LATEXPKGDOCS),$(LATEXPKGTYPESETDIR)/$(LATEXPKG).pdf))

doc: $(LATEXPKGDOCS)
	$(pushDeploymentArtifact)

# build TDS and CTAN archives for CTAN

export CTAN_DIRECTORY := /fonts/$(LATEXPKG)
export LICENSE := free
export FREEVERSION := ofl
export NAME := Sergey S. Betke
export EMAIL := Sergey.S.Betke@yandex.ru

include $(ITG_MAKEUTILS_DIR)/TeX/CTAN.mk

.CTAN: $(LATEXPKGINSTALLFILES) $(LATEXPKGSOURCEFILES)
.CTAN: $(LATEXPKGDOCS) $(wildcard $(LATEXPKGMAINDIR)/*.md)
.CTAN: $(ttfTARGETS) $(otfTARGETS) $(filter %.pfm %.tfm,$(pstype1TARGETS))

clean::
	rm -f $(LATEXPRJVERSIONFILE)
