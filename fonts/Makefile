###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

all: fonts

###

FONTPRJDIR         ?=
FONT               := GOST2.304-81TypeA
FONTSSRCDIR        := $(FONTPRJDIR)sources
FONTSOUTPUTDIR     := $(FONTPRJDIR)bin
FONTSAUXDIR        := $(FONTPRJDIR)obj
FONTSTOOLSDIR      := $(FONTPRJDIR)tools
FONTSTOOLSLIBS     := $(FONTSTOOLSDIR)/itgFontLib.py
fontsTARGET        := $(FONTSOUTPUTDIR)/fonts.zip

# include make packages

FONTS_PACKAGES_DIR ?= packages/
ITG_MAKEUTILS_DIR  ?= $(FONTS_PACKAGES_DIR)ITG.MakeUtils

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

AUTOHINT           ?= ttfautohint
FONTFORGE          ?= fontforge \
	-nosplash
ifeq ($(OS),Windows_NT)
PY                 ?= ffpython
else
PY                 ?= python
endif
TTFAUTOHINT        ?= $(FONTSTOOLSDIR)/ttfautohint \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--composites \
	--strong-stem-width="gGD" \
	--no-info
#	FASTFONT         ?= fastfont

# generate aux .sfd files

FULLSTROKEDFONTSFD	:= $(FONTSAUXDIR)/$(FONT)-stroked-full-aux.sfd
FFBUILDSTROKEDSFD	:= $(FONTSTOOLSDIR)/build-stroked-sfd.py
FFBUILDSTROKEDSFDPRE:=

$(FULLSTROKEDFONTSFD): $(FONTSSRCDIR)/$(FONT).sfd $(FONTSSRCDIR)/$(FONT).fea $(FFBUILDSTROKEDSFD) $(FFBUILDSTROKEDSFDPRE) $(FONTSTOOLSLIBS)
	$(info Build additional glyphs, additional .sfd processing for stroked font...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSTROKEDSFD) $< $(<:.sfd=.fea) $@ $(FULLVERSION)

# generate aux regular .sfd file

REGULARFONTSFD		:= $(FONTSAUXDIR)/$(FONT)-Regular.sfd
FFBUILDREGULARSFD	:= $(FONTSTOOLSDIR)/build-regular-sfd.py

#$(REGULARFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDREGULARSFD) $(FONTSTOOLSLIBS)
#	$(info Build stroked regular font .sfd file "$@"...)
#	$(MAKETARGETDIR)
#	$(PY) $(FFBUILDREGULARSFD) $< $@

$(eval $(call copyfile,$(REGULARFONTSFD),$(FULLSTROKEDFONTSFD)))

# generate aux slanted .sfd file

SLANTEDFONTSFD		:= $(FONTSAUXDIR)/$(FONT)-Slanted.sfd
FFBUILDSLANTEDSFD	:= $(FONTSTOOLSDIR)/build-slanted-sfd.py

$(SLANTEDFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDSLANTEDSFD) $(FONTSTOOLSLIBS)
	$(info Build stroked slanted font .sfd file "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFBUILDSLANTEDSFD) $< $@

# stroke font -> outline font

FFEXPANDSTROKE	:= $(FONTSTOOLSDIR)/expand-stroke-sfd.py

$(FONTSAUXDIR)/%-outline.sfd: $(FONTSAUXDIR)/%.sfd $(FFEXPANDSTROKE) $(FONTSTOOLSLIBS)
	$(info Expand stroke font to outline font "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFEXPANDSTROKE) $< $@

# autokern outline font

FFAUTOKERN		:= $(FONTSTOOLSDIR)/autokern-classes-sfd.py

$(FONTSAUXDIR)/%-autokern.sfd: $(FONTSAUXDIR)/%-outline.sfd $(FFAUTOKERN) $(FONTSTOOLSLIBS)
	$(info Auto kerning outline font "$@"...)
	$(MAKETARGETDIR)
	$(PY) $(FFAUTOKERN) $< $@

# all FontForge aux projects

LASTSFDLABEL    := autokern
FONTVARIANTS		:= Regular Slanted
FONTALLSFD			:= $(foreach VARIANT, $(FONTVARIANTS), $(FONTSAUXDIR)/$(FONT)-$(VARIANT)-$(LASTSFDLABEL).sfd)

# $(call generateTargetFromSources, type, target, sources)
define generateTargetFromSources

FFGENERATE$(1)  ?= $(FONTSTOOLSDIR)/generate-$(1).py
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

$(1)DIR         ?= $(FONTSOUTPUTDIR)/$(1)
FFGENERATE$(1)  ?= $(FONTSTOOLSDIR)/generate-$(1).py
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
  $(1)SOURCES   ?= $(FONTSAUXDIR)/%-$(LASTSFDLABEL).sfd
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

export ttfDIR := $(FONTSOUTPUTDIR)/ttf
$(eval $(call pushArtifactTargets,ttfDIR))
FFGENERATEttf := $(FONTSTOOLSDIR)/generate-ttf.py
export ttfTARGETS := $(foreach VARIANT, $(FONTVARIANTS), $(ttfDIR)/$(FONT)-$(VARIANT).ttf)
$(eval $(call pushArtifactTargets,ttfTARGETS))

ifeq ($(AUTOHINT),ttfautohint)

$(FONTSAUXDIR)/%-beforehinting.ttf: $(FONTSAUXDIR)/%-autokern.sfd $(FFGENERATEttf) $(FONTSTOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(MAKETARGETDIR)
	$(FONTFORGE) -script $(FFGENERATEttf) $@ $<

$(FONTSAUXDIR)/%.ttf: $(FONTSAUXDIR)/%-beforehinting.ttf
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@

else

ifeq ($(AUTOHINT),fontforge)
	FFGENERATEttf	:= $(FONTSTOOLSDIR)/generate-autohinted-ttf.py
endif

$(FONTSAUXDIR)/%.ttf: $(FONTSAUXDIR)/%-autokern.sfd $(FFGENERATEttf) $(FONTSTOOLSLIBS)
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) -script $(FFGENERATEttf) $@ $<

endif 

$(ttfDIR)/%.ttf: $(FONTSAUXDIR)/%.ttf $(CODE_SIGNING_CERTIFICATE_TARGETS)
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

$(eval $(call copyFilesToZIP,$(fontsTARGET),$(foreach target,ttf ttc woff otf pstype0 pstype1,$($(target)TARGETS)),$(FONTSOUTPUTDIR)))

fonts: $(fontsTARGET) | ttf ttc woff otf pstype0 pstype1
	$(pushDeploymentArtifact)

clean::
	rm -rf $(FONTSAUXDIR)
	rm -rf $(FONTSOUTPUTDIR)
	rm -rf $(FONTS_PACKAGES_DIR)
