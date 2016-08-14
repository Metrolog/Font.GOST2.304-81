###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

ITG_MAKEUTILS_DIR ?= ITG.MakeUtils

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk
include $(ITG_MAKEUTILS_DIR)/fontforge/fontforge.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

all: fonts

FONT               := GOST2.304-81TypeA
fontsTARGET        := $(OUTPUTDIR)/fonts.zip

# generate aux .sfd files

FULLSTROKEDFONTSFD	:= $(AUXDIR)/$(FONT)-stroked-full-aux.sfd
FFBUILDSTROKEDSFD	:= $(TOOLSDIR)build-stroked-sfd.py
FFBUILDSTROKEDSFDPRE:=

$(FULLSTROKEDFONTSFD): $(SOURCESDIR)/$(FONT).sfd $(SOURCESDIR)/$(FONT).fea $(FFBUILDSTROKEDSFD) $(FFBUILDSTROKEDSFDPRE) $(FONTSTOOLSLIBS)
	$(info Build additional glyphs, additional .sfd processing for stroked font...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSTROKEDSFD) $< $(<:.sfd=.fea) $@ $(FULLVERSION)

# generate aux regular .sfd file

REGULARFONTSFD		:= $(AUXDIR)/$(FONT)-Regular.sfd
FFBUILDREGULARSFD	:= $(TOOLSDIR)build-regular-sfd.py

#$(REGULARFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDREGULARSFD) $(FONTSTOOLSLIBS)
#	$(info Build stroked regular font .sfd file "$@"...)
#	$(MAKETARGETDIR)
#	$(PY) $(FFBUILDREGULARSFD) $< $@

$(eval $(call copyfile,$(REGULARFONTSFD),$(FULLSTROKEDFONTSFD)))

# generate aux slanted .sfd file

SLANTEDFONTSFD		:= $(AUXDIR)/$(FONT)-Slanted.sfd
FFBUILDSLANTEDSFD	:= $(TOOLSDIR)build-slanted-sfd.py

$(SLANTEDFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDSLANTEDSFD) $(FONTSTOOLSLIBS)
	$(info Build stroked slanted font .sfd file "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSLANTEDSFD) $< $@

# stroke font -> outline font

FFEXPANDSTROKE	:= $(TOOLSDIR)expand-stroke-sfd.py

$(AUXDIR)/%-outline.sfd: $(AUXDIR)/%.sfd $(FFEXPANDSTROKE) $(FONTSTOOLSLIBS)
	$(info Expand stroke font to outline font "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFEXPANDSTROKE) $< $@

# autokern outline font

FFAUTOKERN		:= $(TOOLSDIR)autokern-classes-sfd.py

$(AUXDIR)/%-autokern.sfd: $(AUXDIR)/%-outline.sfd $(FFAUTOKERN) $(FONTSTOOLSLIBS)
	$(info Auto kerning outline font "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFAUTOKERN) $< $@

# all FontForge aux projects

LASTSFDLABEL    := autokern
FONTVARIANTS		:= Regular Slanted
FONTALLSFD			:= $(foreach VARIANT, $(FONTVARIANTS), $(AUXDIR)/$(FONT)-$(VARIANT)-$(LASTSFDLABEL).sfd)

# $(call generateTargetFromSources, type, target, sources)
define generateTargetFromSources

FFGENERATE$(1)  ?= $(TOOLSDIR)generate-$(1).py
$(1)DEPS        ?= $$(FFGENERATE$(1)) $(FONTSTOOLSLIBS)
export $(1)TARGETS ?= $2
$(call pushArtifactTargets,$(1)TARGETS)
$(1)SOURCES     ?= $3

$$($(1)TARGETS): $$($(1)SOURCES) $$($(1)DEPS) $(CODE_SIGNING_CERTIFICATE_TARGETS)
	$$(info Generate $1 font file "$$@"...)
	$$(MAKETARGETDIR)
	$$(FONTFORGE) -script $$(FFGENERATE$(1)) $$@ $$($(1)SOURCES)
	$$(SIGNTARGET)
.PHONY: $1
$(1): $$($(1)TARGETS)

endef

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
	$$(SIGNTARGET)

.PHONY: $1
$(1): $$($(1)TARGETS)

$(call defineTest,check_sign,$(1),\
  $$(call SIGNTESTS,$$^), \
  $$($(1)TARGETS) \
)

endef

# build True Type fonts

export ttfDIR := $(OUTPUTDIR)/ttf
$(eval $(call pushArtifactTargets,ttfDIR))
FFGENERATEttf := $(TOOLSDIR)generate-ttf.py
export ttfTARGETS := $(foreach VARIANT, $(FONTVARIANTS), $(ttfDIR)/$(FONT)-$(VARIANT).ttf)
$(eval $(call pushArtifactTargets,ttfTARGETS))

ifeq ($(AUTOHINT),ttfautohint)

$(AUXDIR)/%-beforehinting.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATEttf) $(FONTSTOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATEttf) $@ $<

$(AUXDIR)/%.ttf: $(AUXDIR)/%-beforehinting.ttf
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@

else

ifeq ($(AUTOHINT),fontforge)
	FFGENERATEttf	:= $(TOOLSDIR)generate-autohinted-ttf.py
endif

$(AUXDIR)/%.ttf: $(AUXDIR)/%-autokern.sfd $(FFGENERATEttf) $(FONTSTOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) -script $(FFGENERATEttf) $@ $<

endif 

$(ttfDIR)/%.ttf: $(AUXDIR)/%.ttf $(CODE_SIGNING_CERTIFICATE_TARGETS)
	#-$(FASTFONT) $<
	$(MAKETARGETDIR)
	cp $< $@
	$(SIGNTARGET)

ttf: $(ttfTARGETS)
	$(pushDeploymentArtifact)

$(eval $(call defineTest,check_sign,ttf,\
  $$(call SIGNTESTS,$$^), \
  $(ttfTARGETS) \
))

# build font files
$(eval $(call generateTargetFromSources,ttc,$(ttfDIR)/$(FONT).ttc,$(ttfTARGETS)))
$(eval $(call generateFontsOfType,woff,woff,$(ttfDIR)/%.ttf))
$(eval $(call generateFontsOfType,otf,otf,,afm))
$(eval $(call generateFontsOfType,pstype0,ps,,afm pfm tfm))
$(eval $(call generateFontsOfType,pstype1,pfb,,afm pfm tfm))

$(eval $(call copyFilesToZIP,$(fontsTARGET),$(foreach target,ttf ttc woff otf pstype0 pstype1,$($(target)TARGETS)),$(OUTPUTDIR)))

fonts: $(fontsTARGET) | ttf ttc woff otf pstype0 pstype1
	$(pushDeploymentArtifact)
