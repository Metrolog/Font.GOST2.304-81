###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

FONTFORGEPROJECTS	:= $(wildcard *.sfd)

FONTSDIR			:= "fonts/"
TTFDIR				:= "ttf/"

# setup tools

FONTFORGE			?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
ifeq ($(OS),Windows_NT)
	RM	:= del /S /Q
endif

###

.DEFAULT_GOAL		:= all

.PHONY: all clean ttf

all: ttf

# build True Type fonts

BUILDTTF			?= $(FONTFORGE) -script build-ttf.pe
TTFTARGETS			:= $(FONTFORGEPROJECTS:.sfd=.ttf)

%.ttf: %.sfd
	$(BUILDTTF) $< $@

ttf: $(TTFTARGETS)

# clean projects

clean:
	$(RM) $(FONTSDIR)
