ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_APPVEYOR_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifeq ($(APPVEYOR),True)

APPVEYORTOOL ?= appveyor

# $(call pushDeploymentArtifactFile, DeploymentName, Path)
#pushDeploymentArtifactFile = $(APPVEYORTOOL) PushArtifact $(2) -DeploymentName $(1)
pushDeploymentArtifactFile = powershell \
  -NoLogo \
  -NonInteractive \
  -Command \& { \
    \$$ErrorActionPreference = \'Stop\'\; \
    \@\( $(foreach file,$(2),,\'$(file)\') \) \
    \| Get-Item \
    \| % { Push-AppveyorArtifact \$$_.FullName -FileName \$$_.Name -DeploymentName ${1} } \
  }

# $(call pushDeploymentArtifactFolder, DeploymentName, Path)
#pushDeploymentArtifactFolder = $(APPVEYORTOOL) PushArtifact $(2) -DeploymentName $(1)
pushDeploymentArtifactFolder = powershell \
  -NoLogo \
  -NonInteractive \
  -Command \& { \
    \$$ErrorActionPreference = \'Stop\'\; \
    \$$root = Resolve-Path \'$(2)\'\; \
    [IO.Directory]::GetFiles\(\$$root.Path, \'*.*\', \'AllDirectories\'\) \
    \| Get-Item \
    \| % { Push-AppveyorArtifact \$$_.FullName -FileName \$$_.FullName.Substring\(\$$root.Path.Length + 1\) -DeploymentName ${1} } \
  }

pushDeploymentArtifact = $(call pushDeploymentArtifactFile,$@,$^)

else

pushDeploymentArtifactFile =
pushDeploymentArtifactFolder =
pushDeploymentArtifact =

endif

endif
