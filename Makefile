###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

FONTFORGEPROJECTS	:= $(wildcard *.sfd)

FONTSDIR			:= fonts
TTFSUBDIR			:= ttf
TTFDIR				:= $(FONTSDIR)/$(TTFSUBDIR)/
TEMPDIR				:= obj
TTFTEMPDIR			:= $(TEMPDIR)/$(TTFSUBDIR)/

# setup tools

FONTFORGE			?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
TTFAUTOHINT			?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" \
						--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
						--windows-compatibility --composites \
						--no-info

ifeq ($(OS),Windows_NT)
	RM				:= del /S/Q
	RMDIR			:= rmdir /S/Q
	MAKETARGETDIR	= $(foreach d,$(subst /, ,${@D}),mkdir $d && cd $d && ) @echo dir "${@D}" created...
else
	RM				:= rm
	RMDIR			:= rmdir
	MAKETARGETDIR	= mkdir -p ${@D}
endif

###

.DEFAULT_GOAL		:= all

.PHONY: all clean ttf

all: ttf

# build True Type fonts

BUILDTTF			?= $(FONTFORGE) -script build-ttf.pe
TTFTARGETS			:= $(FONTFORGEPROJECTS:%.sfd=$(TTFDIR)%.ttf)

$(TTFTEMPDIR)%.ttf: %.sfd
	-$(MAKETARGETDIR)
	$(BUILDTTF) $< $@
	
$(TTFDIR)%.ttf: $(TTFTEMPDIR)%.ttf
	-$(MAKETARGETDIR)
	$(TTFAUTOHINT) $< $@

ttf: $(TTFTARGETS)

# clean projects

clean:
	-$(RMDIR) $(TEMPDIR)
	-$(RMDIR) $(FONTSDIR)
