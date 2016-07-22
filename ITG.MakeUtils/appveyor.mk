ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_APPVEYOR_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifeq ($(APPVEYOR),True)

APPVEYORTOOL ?= appveyor

# $(call pushDeploymentArtifactFile, DeploymentName, Path)
pushDeploymentArtifactFile = $(APPVEYORTOOL) PushArtifact $(2) -DeploymentName $(1)

# $(call pushDeploymentArtifactFolder, DeploymentName, Path)
pushDeploymentArtifactFolder = $(APPVEYORTOOL) PushArtifact $(2) -DeploymentName $(1) -Type zip

pushDeploymentArtifact = $(call pushDeploymentArtifactFile,$@,$^)

else

pushDeploymentArtifactFile =
pushDeploymentArtifactFolder =
pushDeploymentArtifact =

endif

endif