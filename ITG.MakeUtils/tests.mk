ifndef MAKE_TESTS_DIR
MAKE_TESTS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_TESTS_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper ?=$(2)

# $(call defineTest,id,targetId,script,dependencies)
define defineTest
.PHONY: test.$(1)-$(2)
test.$(1)-$(2): $(4)
	@echo ===============================================================================
	@echo Test \"$$@\"...
	$(call testPlatformWrapper,$$@,$3)
	@echo Test OK.
	@echo ===============================================================================

.PHONY: test-$(2)
test-$(2): | test.$(1)-$(2)

test: | test-$(2)

endef

endif