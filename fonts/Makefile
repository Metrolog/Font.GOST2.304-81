###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

.DEFAULT_GOAL		:= all


.PHONY: all
all: ttf ttc woff otf pstype0 pstype1

.SECONDARY:;

.SECONDEXPANSION:;

.DELETE_ON_ERROR:;

###

FONT               := GOST2.304-81TypeA
SRCDIR             := sources
OUTPUTDIR          := bin
AUXDIR             := obj
TOOLSDIR           := tools
TOOLSLIBS          := $(TOOLSDIR)/itgFontLib.py

# setup tools

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk

# fontforge, ttfautohint or no
AUTOHINT           ?= ttfautohint
FONTFORGE          ?= fontforge \
	-nosplash
PY                 ?= ffpython
TTFAUTOHINT        ?= $(TOOLSDIR)/ttfautohint \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--composites \
	--strong-stem-width="gGD" \
	--no-info
#	FASTFONT         ?= fastfont

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

ttfDIR          := $(OUTPUTDIR)/ttf
FFGENERATEttf   := $(TOOLSDIR)/generate-ttf.py
ttfTARGETS      := $(foreach VARIANT, $(FONTVARIANTS), $(ttfDIR)/$(FONT)-$(VARIANT).ttf)

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

# clean projects

.PHONY: clean
clean:
	rm -rf $(AUXDIR)
	rm -rf $(OUTPUTDIR)
