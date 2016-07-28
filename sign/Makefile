###
### GNU make Makefile for update .pvk and .spc files from .pfx
###

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk

.PHONY: cert-prepare
cert-prepare: pvk spc
