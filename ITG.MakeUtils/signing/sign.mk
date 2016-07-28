ifndef MAKE_SIGNING_SIGN_DIR
MAKE_SIGNING_SIGN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_SIGNING_SIGN_DIR)/..)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/nuget.mk

# update .pvk and .spc files from .pfx

$(eval $(call defineNugetPackagesConfig,$(MAKE_SIGNING_SIGN_DIR)/packages.config,$(MAKE_SIGNING_SIGN_DIR)/packages))

SIGNCERTIFICATE ?= cert
SIGNCERTIFICATEPFX ?= $(SIGNCERTIFICATE).pfx
SIGNCERTIFICATEPVK ?= $(SIGNCERTIFICATE).pvk
SIGNCERTIFICATESPC ?= $(SIGNCERTIFICATE).spc

OPENSSL ?= $(MAKE_SIGNING_SIGN_DIR)/packages/OpenSSL/bin/openssl

%_key.pem: %.pfx $(OPENSSL)
	$(OPENSSL) pkcs12 -in $< -nocerts -nodes -out $@

%.pvk: %_key.pem $(OPENSSL)
	$(OPENSSL) rsa -in $< -outform PVK -pvk-strong -out $@

%_cert.pem: %.pfx $(OPENSSL)
	$(OPENSSL) pkcs12 -in $< -nokeys -out $@

%.spc: %_cert.pem $(OPENSSL)
	$(OPENSSL) crl2pkcs7 -nocrl -certfile $< -outform DER -out $@

.PHONY: pvk
pvk: $(SIGNCERTIFICATE).pvk

.PHONY: spc
spc: $(SIGNCERTIFICATE).spc

clean::
	rm -rf $(MAKE_SIGNING_SIGN_DIR)/packages

endif
