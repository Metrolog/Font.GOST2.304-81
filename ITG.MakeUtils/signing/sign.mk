ifndef MAKE_SIGNING_SIGN_DIR
MAKE_SIGNING_SIGN_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_SIGNING_SIGN_DIR)/..)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/nuget.mk

# update .pvk and .spc files from .pfx

SIGNCERTIFICATE ?= cert
SIGNCERTIFICATEPFX ?= $(SIGNCERTIFICATE).pfx
SIGNCERTIFICATEPVK ?= $(SIGNCERTIFICATE).pvk
SIGNCERTIFICATESPC ?= $(SIGNCERTIFICATE).spc

OPENSSL ?= openssl

CERTUTIL := certutil

$(call exportCodeSigningCertificate,filePath)
define exportCodeSigningCertificate
$1:
	$$(MAKETARGETDIR)
	powershell \
    -NoLogo \
    -NonInteractive \
    -NoProfile \
    -ExecutionPolicy unrestricted \
    -File $(call winPath,$(MAKE_SIGNING_SIGN_DIR)/Export-CodeSigningCertificate.ps1) \
    -FilePath $$@ \
    -ErrorAction Stop \
    -Verbose

endef

ifndef CODE_SIGNING_PRIVATE_KEY
%_key.pem:
	$(file > $@,-----BEGIN PRIVATE KEY-----)
	$(file >> $@,$(CODE_SIGNING_PRIVATE_KEY))
	$(file >> $@,-----END PRIVATE KEY-----)
%_cert.pem:
	$(file > $@,$(CODE_SIGNING_PRIVATE_KEY))
else
%_key.pem: %.pfx
	$(OPENSSL) pkcs12 -in $< -nocerts -nodes -out $@
%_cert.pem: %.pfx
	$(OPENSSL) pkcs12 -in $< -nokeys -out $@
endif

%.pvk: %_key.pem
	$(OPENSSL) rsa -in $< -outform PVK -pvk-strong -out $@

%.spc: %_cert.pem
	$(OPENSSL) crl2pkcs7 -nocrl -certfile $< -outform DER -out $@

.PHONY: pvk
pvk: $(SIGNCERTIFICATE).pvk

.PHONY: spc
spc: $(SIGNCERTIFICATE).spc

endif
