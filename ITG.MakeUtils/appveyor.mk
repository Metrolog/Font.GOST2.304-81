ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(MAKE_APPVEYOR_DIR)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/nuget.mk

ifeq ($(APPVEYOR),True)

APPVEYORTOOL := appveyor

# $(call pushDeploymentArtifactFile, DeploymentName, Path)
pushDeploymentArtifactFile = for file in $2; do $(APPVEYORTOOL) PushArtifact $$file -DeploymentName '$(1)'; done

pushDeploymentArtifact = $(call pushDeploymentArtifactFile,$@,$^)

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = echo Test \"$1\" $2$(if $3, in $3 ms).

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  set +e; \
  $(call testPlatformSetStatus,$1,Running); \
  $(APPVEYORTOOL) AddTest -Name "$1" -Framework "MSTest" -FileName "" -Outcome Running; \
  STD_OUT_FILE=$$$$(mktemp); \
  STD_ERR_FILE=$$$$(mktemp); \
  START_TIME=$$$$(($$$$(date +%s%3N))); \
  ( $2 ) > $$$$STD_OUT_FILE 2> $$$$STD_ERR_FILE; \
  EXIT_CODE=$$$$?; \
  FINISH_TIME=$$$$(($$$$(date +%s%3N))); \
  DURATION=$$$$(($$$$FINISH_TIME-$$$$START_TIME)); \
  STD_OUT="$$$$(cat $$$$STD_OUT_FILE)"; \
  STD_ERR="$$$$(cat $$$$STD_ERR_FILE)"; \
  echo $$$$STD_OUT; \
  if [[ $$$$EXIT_CODE -eq 0 ]]; then \
    $(call testPlatformSetStatus,$1,Passed,$$$$DURATION); \
    $(APPVEYORTOOL) UpdateTest -Name "$1" -Duration $$$$DURATION -Framework "MSTest" -FileName "" -Outcome Passed -StdOut "$$$$STD_OUT"; \
  else \
    $(call testPlatformSetStatus,$1,Failed,$$$$DURATION); \
    $(APPVEYORTOOL) UpdateTest -Name "$1" -Duration $$$$DURATION -Framework "MSTest" -FileName "" -Outcome Failed -StdOut "$$$$STD_OUT" -StdErr "$$$$STD_ERR"; \
  fi; \
  exit $$$$EXIT_CODE;

OPENSSL := $(call shellPath,C:\OpenSSL-Win64\bin\openssl.exe)

else

pushDeploymentArtifactFile =
pushDeploymentArtifact =

endif

SECURE_FILE_TOOL ?= $(NUGET_PACKAGES_DIR)/secure-file/tools/secure-file
SECURE_FILES_SECRET ?= password

getEncodedFile = $1.enc

# $(call encodeFile, to, from, secret)
define encodeFile
$(if $1,$1,$(call getEncodedFile,$2)): $2 | $$(SECURE_FILE_TOOL)
	$$(MAKETARGETDIR)
	$$(SECURE_FILE_TOOL) \
    -secret $$(if $3,$3,$$(SECURE_FILES_SECRET)) \
    -encrypt $$(call winPath,$$<) \
    -out $$(call winPath,$$@)

endef

# $(call decodeFile, to, from, secret)
define decodeFile
$1: $(if $2,$2,$(call getEncodedFile,$1)) | $$(SECURE_FILE_TOOL)
	$$(MAKETARGETDIR)
	$$(SECURE_FILE_TOOL) \
    -secret $$(if $3,$3,$$(SECURE_FILES_SECRET)) \
    -decrypt $$(call winPath,$$<) \
    -out $$(call winPath,$$@)

endef

endif
