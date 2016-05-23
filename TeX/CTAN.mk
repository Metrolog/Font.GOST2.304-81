ifndef MAKE_TEX_CTAN_DIR
MAKE_TEX_CTAN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(MAKE_TEX_CTAN_DIR)/../common.mk

# $(call copyFilesToTarget, targetId, type, sourceFiles, targetDir, filter, filterid)
define copyFilesToTarget
ifneq ($(strip $(4)),)
  LATEX$(1)$(2)$(6)PATH := $(LATEX$(1)AUXDIR)/$(4)
else
  LATEX$(1)$(2)$(6)PATH := $(LATEX$(1)AUXDIR)
endif
ifneq ($(strip $(5)),)
  LATEX$(1)$(2)$(6)SOURCES = $(filter $(foreach tmpl,$(5),%.$(tmpl)),$(3))
else
  LATEX$(1)$(2)$(6)SOURCES = $(3)
endif
LATEX$(1)$(2)$(6)TARGETS = $$(foreach file,$$(LATEX$(1)$(2)$(6)SOURCES),$$(LATEX$(1)$(2)$(6)PATH)/$$(notdir $$(file)))
$(1)FILES += $$(LATEX$(1)$(2)$(6)TARGETS)
$$(foreach file,$$(LATEX$(1)$(2)$(6)SOURCES),$$(eval $$(call copyfile,$$(LATEX$(1)$(2)$(6)PATH)/$$(notdir $$(file)),$$(file))))
endef

# $(call copyFilesToTDS, type, sourceFiles, targetDir, filter, filterid)
copyFilesToTDS = $(call copyFilesToTarget,TDS,$(1),$(2),$(3),$(4),$(5))

# $(call copyFilesToCTAN, type, sourceFiles, targetDir, filter, filterid)
copyFilesToCTAN = $(call copyFilesToTarget,CTAN,$(1),$(2),$(3),$(4),$(5))

endif