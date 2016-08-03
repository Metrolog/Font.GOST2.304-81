ifndef MAKE_TESTS_DIR
MAKE_TESTS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_TESTS_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = echo Test \"$1\" $2$(if $3, in $3 ms).

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  set +e; \
  $(call testPlatformSetStatus,$1,Running); \
  START_TIME=$$$$(($$$$(date +%s%3N))); \
  ( $2 ); \
  EXIT_CODE=$$$$?; \
  FINISH_TIME=$$$$(($$$$(date +%s%3N))); \
  DURATION=$$$$(($$$$FINISH_TIME-$$$$START_TIME)); \
  if [[ $$$$EXIT_CODE -eq 0 ]]; then \
    $(call testPlatformSetStatus,$1,Passed,$$$$DURATION); \
  else \
    $(call testPlatformSetStatus,$1,Failed,$$$$DURATION); \
  fi; \
  exit $$$$EXIT_CODE;

# $(call defineTest,id,targetId,script,dependencies)
define defineTest
.PHONY: test.$(1)-$(2)
test.$(1)-$(2): $(4)
	@echo ===============================================================================
	@$(call testPlatformWrapper,$$@,$3)
	@echo ===============================================================================

.PHONY: test-$(2)
test-$(2): | test.$(1)-$(2)

test: | test-$(2)

endef

endif