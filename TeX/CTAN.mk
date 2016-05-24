ifndef MAKE_TEX_CTAN_DIR
MAKE_TEX_CTAN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

LATEXTDSAUXDIR ?= $(AUXDIR)/tds
LATEXTDSAUXINCDIR ?= $(AUXDIR)/tds.mk
TDSFILE ?= $(LATEXPKG).tds.zip
TDSTARGET ?= $(AUXDIR)/$(TDSFILE)

include $(MAKE_TEX_CTAN_DIR)../common.mk

LATEXTDSPHONYDIR := PHONYDIR

# $(call defineTDSRule, source, target)
define defineTDSRule
$(LATEXTDSAUXINCDIR)/$(1).mk: $(LATEXTDSAUXDIR)/$(2) $(MAKEFILE_LIST)
	$$(MAKETARGETDIR)
	echo $$(TDSTARGET): $$< > $$@
endef
copyFileToTDSaux = include $(LATEXTDSAUXINCDIR)/$(1).mk

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

# $(call copyFilesToTDS, sourceFiles)
define copyFilesToTDS
$(foreach file,$(1),$(eval
  $(call copyfileto,$(LATEXTDSAUXDIR)/%,$(file))
  $(call copyFileToTDSaux,$(notdir $(file)))
))
endef

# $(call copyFilesToTarget, targetId, type, sourceFiles, targetDir)
define copyFilesToTarget
$(foreach file,$(3),$(eval $(call copyfileto,$(LATEX$(1)AUXDIR)/$(4),$(file))))
$($(1)TARGET): $(foreach file,$(3),$(LATEX$(1)AUXDIR)/$(4)/$(notdir $(file)))
endef

TDSTARGETS := $(TDSTARGET)($(foreach file,$(TDSFILES),$(patsubst $(LATEXTDSAUXDIR)/%,%,$(file))))
$(eval $(call copyFilesToZIP,$(TDSTARGET),,$(LATEXTDSAUXDIR)))
.PHONY: tds
tds: $(TDSTARGET)

# $(call copyFilesToCTAN, type, sourceFiles, targetDir)
copyFilesToCTAN = $(call copyFilesToTarget,CTAN,$(1),$(2),$(3))

endif