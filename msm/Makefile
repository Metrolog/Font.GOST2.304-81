#
# GNU make Makefile for build GOST 2.304-81 MSI module (msm)
# 
# The build machine must have WiX 4.0 installed 
# 

.DEFAULT_GOAL		:= msm

.PHONY: clean msm msi

.SECONDARY:;

.SECONDEXPANSION:;

.DELETE_ON_ERROR:;

SolutionName			:= GOST2.304-81
ProjectName				:= MSM
TargetName				:= $(SolutionName)

WXIFILES				?=

Culture					:= ru-ru

WIXLIBS					?= ITG.WixUtils
vpath %.wixlib ../ITG.WixUtils/bin/Release

SuppressICEs			:= ICEM09

ProjectDir				?= $(CURDIR)/
OutputDir				?= bin/
IntermediateOutputDir	?= obj/
Configuration			?= Release
Platform				?= x86
Culture					?= en-en
SuppressICEs			?= 
TargetExt				?= .msm
TargetFileName			?= $(TargetName)$(TargetExt)
TargetFullName			?= $(OutputPath)$(TargetFileName)

WXSFILES				?= $(wildcard *.wxs)
WXLFILES				?= $(wildcard *.wxl) $(wildcard $(Culture)/*.wxl)

#

ifdef MSBuildExtensionsPath32
	WixTargetsPath		?= $(MSBuildExtensionsPath32)\WiX Toolset\v4\Wix.targets
endif
ifdef MSBuildExtensionsPath
	WixTargetsPath		?= $(MSBuildExtensionsPath)\WiX Toolset\v4\Wix.targets
endif

OutputPath				?= $(OutputDir)$(Configuration)/
IntermediateOutputPath	?= $(IntermediateOutputDir)$(Configuration)/

ifeq ($(OS),Windows_NT)
	MAKETARGETDIR		:= cd $(dir ${@D}) && mkdir $(notdir ${@D})
	WIXDIR				?= %ProgramFiles(x86)%/WiX Toolset v4.0/bin/
	CANDLE				?= "$(WIXDIR)candle.exe"
	LIGHT				?= "$(WIXDIR)light.exe"
	PATHSEP				:=;
else
	MAKETARGETDIR		:= mkdir -p ${@D}
	CANDLE				?= candle.exe
	LIGHT				?= light.exe
	PATHSEP				:=:
endif

clean:
	$(info Erase build directories...)
	rm -rf $(OutputDir)
	rm -rf $(IntermediateOutputDir)

vpath %.wixobj $(IntermediateOutputDir)$(Configuration)

%.wixobj: %.wxs $(WXIFILES);
	$(CANDLE) \
		-nologo \
		-out $(IntermediateOutputPath) \
		-dSolutionName=$(SolutionName) \
		-dConfiguration=$(Configuration) \
		-dOutDir=$(OutputPath) \
		-dPlatform=$(Platform) \
		-dProjectDir=$(ProjectDir) \
		-dProjectName=$(ProjectName) \
		-dTargetDir=$(ProjectDir)$(OutputPath) \
		-dTargetName=$(TargetName) \
		-dTargetExt=$(TargetExt) \
		-dTargetFileName=$(TargetFileName) \
		-dTargetPath=$(ProjectDir)$(OutputPath)$(TargetFileName) \
		-arch $(Platform) \
		$<

.LIBPATTERNS			:= %.wixlib
WIXOBJFILES				:= $(patsubst %.wxs,%.wixobj,$(WXSFILES))

vpath %.msm $(OutputDir)$(Configuration)

%.msm %.msi:;
	$(LIGHT) \
		-nologo \
		-sice:$(SuppressICEs) \
		-out $@ \
		-cultures:$(Culture) \
		$(foreach locfile,$(filter %.wxl,$^),-loc $(realpath $(locfile)) ) \
		$(foreach objfile,$(filter %.wixobj,$^),$(IntermediateOutputPath)/$(objfile)) \
		$(foreach libfile,$(filter %.wixlib,$^),$(realpath $(libfile)))

$(TargetFullName): $(WIXOBJFILES) $(WXLFILES) $(foreach lib,$(WIXLIBS), -l$(lib))

msm: $(TargetFullName)

msi: $(TargetFullName)
