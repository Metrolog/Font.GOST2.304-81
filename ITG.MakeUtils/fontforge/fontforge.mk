ifndef MAKE_FONTFORGE_CTAN_DIR
MAKE_FONTFORGE_CTAN_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_FONTFORGE_CTAN_DIR)/..)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk

TOOLSDIR           ?= tools/
FONTSTOOLSLIBS     := $(TOOLSDIR)itgFontLib.py

FONTFORGE          ?= fontforge \
	-nosplash

ifeq ($(OS),Windows_NT)
PY                 ?= ffpython
else
PY                 ?= python
endif

AUTOHINT           ?= ttfautohint
TTFAUTOHINT        ?= \
  $(TOOLSDIR)ttfautohint \
    --hinting-range-min=8 \
    --hinting-range-max=88 \
    --hinting-limit=220 \
    --increase-x-height=22 \
    --windows-compatibility \
    --composites \
    --strong-stem-width="gGD" \
    --no-info
FASTFONT           ?= fastfont


# $(call generateFontsOfType, type, fileext, [sourceFileTemplate], [ расширения файлов-сателитов (без точек)] )
define generateFontsOfType

$(1)DIR         ?= $(OUTPUTDIR)/$(1)
FFGENERATE$(1)  ?= $(TOOLSDIR)generate-$(1).py
$(1)DEPS        ?= $$(FFGENERATE$(1)) $(FONTSTOOLSLIBS)
$(1)EXT         ?= $2
export $(1)MAINTARGETS := $(foreach VARIANT,$(FONTVARIANTS),$$($(1)DIR)/$(FONT)-$(VARIANT).$$($(1)EXT))
$(call pushArtifactTargets, $(1)MAINTARGETS)
$(1)EXTS        ?= $4
export $(1)TARGETS := $$($(1)MAINTARGETS) $$(foreach ext,$$($(1)EXTS),$$($(1)MAINTARGETS:.$$($(1)EXT)=.$$(ext)))
$(call pushArtifactTargets, $(1)TARGETS)
ifneq ($(strip $3),)
  $(1)SOURCES   ?= $3
else
  $(1)SOURCES   ?= $(AUXDIR)/%-$(LASTSFDLABEL).sfd
endif

$$($(1)DIR)/%.$$($(1)EXT) $$(foreach ext,$$($(1)EXTS),$$($(1)DIR)/%.$$(ext)): $$($(1)SOURCES) $$($(1)DEPS) $(CODE_SIGNING_CERTIFICATE_TARGETS)
	$$(info Generate .$2 font file "$$@"...)
	$$(MAKETARGETDIR)
	$$(FONTFORGE) -script $$(FFGENERATE$(1)) $$($(1)DIR)/$$*.$$($(1)EXT) $$(filter-out $$($(1)DEPS),$$^)
	$(if $(CODE_SIGNING_CERTIFICATE_TARGETS),$$(SIGNTARGET))

.PHONY: $1
$(1): $$($(1)TARGETS)

$(if $(CODE_SIGNING_CERTIFICATE_TARGETS),\
$(call defineTest,check_sign,$(1),\
  $$(call SIGNTESTS,$$^), \
  $$($(1)TARGETS) \
)\
)

endef

endif