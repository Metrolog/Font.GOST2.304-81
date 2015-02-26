###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

FONTFORGEPROJECTS	:= $(wildcard *.sfd)

FONTSDIR			:= fonts
TTFSUBDIR			:= ttf
TTFDIR				:= $(FONTSDIR)/$(TTFSUBDIR)/

# setup tools

FONTFORGE			?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
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

$(TTFDIR)%.ttf: %.sfd
	-$(MAKETARGETDIR)
	$(BUILDTTF) $< $@
	
ttf: $(TTFTARGETS)

# clean projects

clean:
	$(RMDIR) $(FONTSDIR)
