###
### GNU make Makefile for update .pvk and .spc files from .pfx
###

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk

CODE_SIGNING_CERTIFICATE ?= certificate/cert1.pfx

$(eval $(call exportCodeSigningCertificate,$(CODE_SIGNING_CERTIFICATE)))

#.PHONY: cert-prepare
#cert-prepare: pvk spc
cert-prepare: $(CODE_SIGNING_CERTIFICATE)
