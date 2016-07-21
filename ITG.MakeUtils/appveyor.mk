ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_APPVEYOR_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifdef APPVEYOR

APPVEYOR ?= appveyor

# $(call pushArtifactFile, DeploymentName, Path)
pushArtifactFile = $(APPVEYOR) PushArtifact $(2) -DeploymentName $(1)

# $(call pushArtifactFolder, DeploymentName, Path)
pushArtifactFolder = $(APPVEYOR) PushArtifact $(2) -DeploymentName $(1) -Type zip

pyshArtifact = $(call pushArtifactFile,$@,$^)

else

pushArtifact =
pushArtifactFolder =
pyshArtifact =

endif

endif