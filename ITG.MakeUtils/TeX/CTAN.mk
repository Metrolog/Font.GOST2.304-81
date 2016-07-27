ifndef MAKE_TEX_CTAN_DIR
MAKE_TEX_CTAN_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_TEX_CTAN_DIR)/..)

LATEXTDSAUXDIR ?= $(AUXDIR)/tds
TDSFILE ?= $(LATEXPKG).tds.zip
TDSTARGET ?= $(AUXDIR)/$(TDSFILE)

LATEXCTANAUXDIR ?= $(AUXDIR)/ctan
CTANFILE ?= $(LATEXPKG).zip
CTANTARGET ?= $(OUTPUTDIR)/ctan/$(CTANFILE)

CTAN_SUMMARYFILE ?= $(LATEXPKGMAINDIR)/summary.txt
export CTAN_DONOTANNOUNCE ?= 1
export CTAN_DIRECTORY ?= /macros/latex/contrib/$(LATEXPKG)
export LICENSE ?= free
export FREEVERSION ?= lppl

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

#
# common
#

# $(call defineCTANTargetRule, TargetType, source, target)
define defineCTANTargetRule
$(LATEX$(1)AUXINCDIR)/$(2).$(1).mk: $(MAKEFILE_LIST) | $(LATEX$(1)AUXDIR)/$(3)
	$$(file > $$@,$$($(1)TARGET): $$|)
endef

define copyFileToCTANTargetByRule
include $(LATEX$(1)AUXINCDIR)/$(notdir $(2)).$(1).mk
endef

# $(call copyFilesToTarget, targetId, sourceFiles, targetDir)
define copyFilesToTarget
$(foreach file,$(2),$(eval $(call copyfileto,$(LATEX$(1)AUXDIR)$(3),$(file))))
$($(1)TARGET): $(foreach file,$(2),$(LATEX$(1)AUXDIR)$(3)/$(notdir $(file)))
endef

# $(call copyFileToCTANTarget, TargetType, sourceFile)
define copyFileToCTANTarget
$(call copyfileto,$(LATEX$(1)AUXDIR)/%,$(2))
$(call copyFileToCTANTargetByRule,$(1),$(2))
endef

# $(call copyFilesToCTANTarget, TargetType, sourceFiles)
define copyFilesToCTANTarget
$(foreach file,$(2),$(eval $(call copyFileToCTANTarget,$(1),$(file))))
endef

#
# build TDS archive
#

LATEXTDSAUXINCDIR ?= $(AUXDIR)

defineTDSRule = $(call defineCTANTargetRule,TDS,$1,$2)
copyFileToTDSByRule = $(call copyFileToCTANTargetByRule,TDS,$1)

$(eval $(call defineTDSRule,README,doc/latex/$(LATEXPKG)/README))
$(eval $(call defineTDSRule,%.afm,fonts/afm/public/$(LATEXPKG)/%.afm))
$(eval $(call defineTDSRule,%.bat,scripts/$(LATEXPKG)/%.bat))
$(eval $(call defineTDSRule,%.bbx,tex/latex/$(LATEXPKG)/%.bbx))
$(eval $(call defineTDSRule,%.bib,bibtex/bib/$(LATEXPKG)/%.bib))
$(eval $(call defineTDSRule,%.bst,bibtex/bst/$(LATEXPKG)/%.bst))
$(eval $(call defineTDSRule,%.cbx,tex/latex/$(LATEXPKG)/%.cbx))
$(eval $(call defineTDSRule,%.cls,tex/latex/$(LATEXPKG)/%.cls))
$(eval $(call defineTDSRule,%.dbx,tex/latex/$(LATEXPKG)/%.dbx))
$(eval $(call defineTDSRule,%.dtx,source/latex/$(LATEXPKG)/%.dtx))
$(eval $(call defineTDSRule,%.dvi,doc/latex/$(LATEXPKG)/%.dvi))
$(eval $(call defineTDSRule,%.fd,tex/latex/$(LATEXPKG)/%.fd))
$(eval $(call defineTDSRule,%.ins,source/latex/$(LATEXPKG)/%.ins))
$(eval $(call defineTDSRule,%.map,fonts/map/dvips/$(LATEXPKG)/%.map))
$(eval $(call defineTDSRule,%.md,doc/latex/$(LATEXPKG)/%.md))
$(eval $(call defineTDSRule,%.mf,fonts/source/public/$(LATEXPKG)/%.mf))
$(eval $(call defineTDSRule,%.mp,metapost/$(LATEXPKG)/%.mp))
$(eval $(call defineTDSRule,%.ofm,fonts/ofm/public/$(LATEXPKG)/%.ofm))
$(eval $(call defineTDSRule,%.otf,fonts/opentype/public/$(LATEXPKG)/%.otf))
$(eval $(call defineTDSRule,%.ovf,fonts/ovf/public/$(LATEXPKG)/%.ovf))
$(eval $(call defineTDSRule,%.ovp,fonts/ovp/public/$(LATEXPKG)/%.ovp))
$(eval $(call defineTDSRule,%.pdf,doc/latex/$(LATEXPKG)/%.pdf))
$(eval $(call defineTDSRule,%.pfb,fonts/type1/public/$(LATEXPKG)/%.pfb))
$(eval $(call defineTDSRule,%.pfm,fonts/type1/public/$(LATEXPKG)/%.pfm))
$(eval $(call defineTDSRule,%.ps,doc/latex/$(LATEXPKG)/%.ps))
$(eval $(call defineTDSRule,%.py,scripts/$(LATEXPKG)/%.py))
$(eval $(call defineTDSRule,%.sh,scripts/$(LATEXPKG)/%.sh))
$(eval $(call defineTDSRule,%.sty,tex/latex/$(LATEXPKG)/%.sty))
$(eval $(call defineTDSRule,%.tfm,fonts/tfm/public/$(LATEXPKG)/%.tfm))
$(eval $(call defineTDSRule,%.ttf,fonts/truetype/public/$(LATEXPKG)/%.ttf))
$(eval $(call defineTDSRule,%.txt,doc/latex/$(LATEXPKG)/%.txt))
$(eval $(call defineTDSRule,%.vf,fonts/vf/public/$(LATEXPKG)/%.vf))

#$(LATEXTDSPHONYDIR)/%:
#	$(error Unknown TDS file extension: $@)

copyFileToTDS = $(call copyFileToCTANTarget,TDS,$1)
copyFilesToTDS = $(call copyFilesToCTANTarget,TDS,$1)

.PHONY: tds
tds: $(TDSTARGET)

#
# build CTAN archive
#

LATEXCTANAUXINCDIR ?= $(AUXDIR)

defineCTANRule = $(call defineCTANTargetRule,CTAN,$1,$2)
copyFileToCTANByRule = $(call copyFileToCTANTargetByRule,CTAN,$1)

$(eval $(call defineCTANRule,README.md,$(LATEXPKG)/README.md))
$(eval $(call defineCTANRule,README.txt,$(LATEXPKG)/README.txt))
$(eval $(call defineCTANRule,README,$(LATEXPKG)/README))
$(eval $(call defineCTANRule,%.afm,$(LATEXPKG)/fonts/%.afm))
$(eval $(call defineCTANRule,%.bat,$(LATEXPKG)/scripts/%.bat))
$(eval $(call defineCTANRule,%.bbx,$(LATEXPKG)/tex/%.bbx))
$(eval $(call defineCTANRule,%.bib,$(LATEXPKG)/bibtex/%.bib))
$(eval $(call defineCTANRule,%.bst,$(LATEXPKG)/bibtex/%.bst))
$(eval $(call defineCTANRule,%.cbx,$(LATEXPKG)/tex/%.cbx))
$(eval $(call defineCTANRule,%.cls,$(LATEXPKG)/tex/%.cls))
$(eval $(call defineCTANRule,%.dbx,$(LATEXPKG)/tex/%.dbx))
$(eval $(call defineCTANRule,%.dtx,$(LATEXPKG)/source/%.dtx))
$(eval $(call defineCTANRule,%.dvi,$(LATEXPKG)/doc/%.dvi))
$(eval $(call defineCTANRule,%.fd,$(LATEXPKG)/tex/%.fd))
$(eval $(call defineCTANRule,%.ins,$(LATEXPKG)/source/%.ins))
$(eval $(call defineCTANRule,%.map,$(LATEXPKG)/fonts/%.map))
$(eval $(call defineCTANRule,%.md,$(LATEXPKG)/doc/%.md))
$(eval $(call defineCTANRule,%.mf,$(LATEXPKG)/source/%.mf))
$(eval $(call defineCTANRule,%.mp,$(LATEXPKG)/metapost/%.mp))
$(eval $(call defineCTANRule,%.ofm,$(LATEXPKG)/fonts/%.ofm))
$(eval $(call defineCTANRule,%.otf,$(LATEXPKG)/fonts/%.otf))
$(eval $(call defineCTANRule,%.ovf,$(LATEXPKG)/fonts/%.ovf))
$(eval $(call defineCTANRule,%.ovp,$(LATEXPKG)/fonts/%.ovp))
$(eval $(call defineCTANRule,%.pdf,$(LATEXPKG)/doc/%.pdf))
$(eval $(call defineCTANRule,%.pfb,$(LATEXPKG)/fonts/%.pfb))
$(eval $(call defineCTANRule,%.pfm,$(LATEXPKG)/fonts/%.pfm))
$(eval $(call defineCTANRule,%.ps,$(LATEXPKG)/doc/%.ps))
$(eval $(call defineCTANRule,%.py,$(LATEXPKG)/scripts/%.py))
$(eval $(call defineCTANRule,%.sh,$(LATEXPKG)/scripts/%.sh))
$(eval $(call defineCTANRule,%.sty,$(LATEXPKG)/tex/%.sty))
$(eval $(call defineCTANRule,%.tfm,$(LATEXPKG)/fonts/%.tfm))
$(eval $(call defineCTANRule,%.ttf,$(LATEXPKG)/fonts/%.ttf))
$(eval $(call defineCTANRule,%.txt,$(LATEXPKG)/doc/%.txt))
$(eval $(call defineCTANRule,%.vf,$(LATEXPKG)/fonts/%.vf))

copyFileToCTAN = $(call copyFileToCTANTarget,CTAN,$1)
copyFilesToCTAN = $(call copyFilesToCTANTarget,CTAN,$1)

$(eval $(call copyFilesToTarget,CTAN,$(TDSTARGET)))

ctan: $(CTANTARGET)
	$(pushDeploymentArtifact)

#
# common
#

# $(call copyFileToTDSandCTAN, sourceFile)
define copyFileToTDSandCTAN
$(call copyFileToTDS,$(1))
$(call copyFileToCTAN,$(1))
endef

ifndef SUBMAKE_TEX_CTAN

CTANMAKEFILE ?= $(AUXDIR)/$(LATEXPKG).ctan.mk

ifndef CTANFILES

.CTAN:
	$(eval export CTANFILES := $^)

$(TDSTARGET) $(CTANTARGET): | .CTAN
	$(MAKE) $@

else

$(CTANMAKEFILE): $(MAKEFILE_LIST)
	$(info Build intermediate makefile for CTAN: $@)
	$(MAKETARGETDIR)
	$(file > $@,# intermediate makefile for CTAN archive)
	$(file >> $@,SUBMAKE_TEX_CTAN := $(dir $(lastword $(MAKEFILE_LIST))))
	$(file >> $@,include Makefile)
	$(foreach ctanfile,$(CTANFILES),$(file >> $@,$(call copyFileToTDSandCTAN,$(ctanfile))))
	$(file >> $@,$(call copyFilesToZIP,$(TDSTARGET),,$(LATEXTDSAUXDIR)))
	$(file >> $@,$(call copyFilesToZIP,$(CTANTARGET),,$(LATEXCTANAUXDIR)))

$(TDSTARGET) $(CTANTARGET): $(CTANMAKEFILE)
	$(MAKE) --makefile $(CTANMAKEFILE) $@

endif

endif

#
# upload to CTAN
#

.PHONY: ctanupload
ctanupload: $(CTANTARGET)
	ctanupload -P -y -U dante -q \
    --file=$< \
    --contribution=$(LATEXPKG) \
    --version=$(VERSION) \
    --summary-file=$(CTAN_SUMMARYFILE) \
    --directory=$(CTAN_DIRECTORY)

endif