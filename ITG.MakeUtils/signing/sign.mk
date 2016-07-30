ifndef MAKE_SIGNING_SIGN_DIR
MAKE_SIGNING_SIGN_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_SIGNING_SIGN_DIR)/..)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/nuget.mk

# update .pvk and .spc files from .pfx

PFX_PASSWORD ?= pfxpassword
OPENSSL ?= openssl
CERTUTIL := certutil

$(call exportCodeSigningCertificate,filePath,password)
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
    -Password '$(PFX_PASSWORD)' \
    -ErrorAction Stop \
    -Verbose

endef

# $(call exportCertificateKeyFromPfx2Pem,PvkPemFile,PfxFile)
define exportCertificateKeyFromPfx2Pem
$1: $2
	$$(MAKETARGETDIR)
	$$(OPENSSL) \
    pkcs12 \
    -nocerts \
    -nodes \
    -passin pass:$(PFX_PASSWORD) \
    -in $$< \
    -out $$@

endef

# $(call exportCertificateFromPfx2Pem,CertPemFile,PfxFile)
define exportCertificateFromPfx2Pem
$1: $2
	$$(MAKETARGETDIR)
	$$(OPENSSL) \
    pkcs12 \
    -nokeys \
    -passin pass:$(PFX_PASSWORD) \
    -in $$< \
    -out $$@

endef

# $(call convertCertificateKeyPem2Pvk,PvkFile,PvkPemFile)
define convertCertificateKeyPem2Pvk
$1: $2
	$$(MAKETARGETDIR)
	$(OPENSSL) \
    rsa \
    -inform PEM \
    -outform PVK \
    -pvk-strong \
    -passin pass:$(PFX_PASSWORD) \
    -passout pass:$(PFX_PASSWORD) \
    -in $$< \
    -out $$@

endef

# $(call convertCertificatePem2Spc,SpcFile,CertPemFile)
define convertCertificatePem2Spc
$1: $2
	$$(MAKETARGETDIR)
	$(OPENSSL) \
    crl2pkcs7 \
    -nocrl \
    -inform PEM \
    -outform DER \
    -in $$< \
    -out $$@

endef

ifndef CODE_SIGNING_PRIVATE_KEY
%_key.pem:
	$(file > $@,-----BEGIN PRIVATE KEY-----)
	$(file >> $@,$(CODE_SIGNING_PRIVATE_KEY))
	$(file >> $@,-----END PRIVATE KEY-----)
%_cert.pem:
	$(file > $@,$(CODE_SIGNING_PRIVATE_KEY))
else
endif

endif
