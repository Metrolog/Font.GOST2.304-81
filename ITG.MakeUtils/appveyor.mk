ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_APPVEYOR_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifeq ($(APPVEYOR),True)

APPVEYORTOOL ?= appveyor

# $(call pushDeploymentArtifactFile, DeploymentName, Path)
pushDeploymentArtifactFile = for file in $2; do $(APPVEYORTOOL) PushArtifact $$file -DeploymentName '$(1)'; done

pushDeploymentArtifact = $(call pushDeploymentArtifactFile,$@,$^)

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  $(APPVEYORTOOL) AddTest -Name "$1" -Framework "xUnit" -FileName "" -Outcome Running; \
  STD_OUT_FILE=$$$$(mktemp); \
  STD_ERR_FILE=$$$$(mktemp); \
  $2 > $$$$STD_OUT_FILE 2> $$$$STD_ERR_FILE; \
  EXIT_CODE=$$$$?; \
  STD_OUT="$$$$(cat $$$$STD_OUT_FILE)"; \
  STD_ERR="$$$$(cat $$$$STD_ERR_FILE)"; \
  echo $$$$STD_OUT; \
  if [[ $$$$EXIT_CODE -eq 0 ]]; then \
    $(APPVEYORTOOL) AddTest -Name "$1" -Framework "xUnit" -FileName "" -Outcome Passed -StdOut $$$$STD_OUT; \
  else \
    $(APPVEYORTOOL) AddTest -Name "$1" -Framework "xUnit" -FileName "" -Outcome Failed -StdOut $$$$STD_OUT -StdErr $$$$STD_ERR; \
  fi; \
  exit $$$$EXIT_CODE;

else

pushDeploymentArtifactFile =
pushDeploymentArtifact =

endif

endif
