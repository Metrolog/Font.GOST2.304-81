ifndef MAKE_SIGNING_SIGN_DIR
MAKE_SIGNING_SIGN_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_SIGNING_SIGN_DIR)/..)

include $(ITG_MAKEUTILS_DIR)/common.mk

CODE_SIGNING_CERTIFICATE_PASSWORD ?= pfxpassword
OPENSSL ?= openssl
SIGNTOOL ?= signtool
SIGNCODE ?= signcode
SIGNCODEPWD ?= signcodepwd
CHKTRUST ?= chktrust

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
    -Password '$(CODE_SIGNING_CERTIFICATE_PASSWORD)' \
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
    -passin pass:$(CODE_SIGNING_CERTIFICATE_PASSWORD) \
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
    -passin pass:$(CODE_SIGNING_CERTIFICATE_PASSWORD) \
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
    -passin pass:$(CODE_SIGNING_CERTIFICATE_PASSWORD) \
    -passout pass:$(CODE_SIGNING_CERTIFICATE_PASSWORD) \
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
    -certfile $$< \
    -out $$@

endef

# $(call convertCertificatePem2Pfx,PfxFile,KeyFile,CertPemFile)
define convertCertificatePem2Pfx
$1: $2 $3
	$$(MAKETARGETDIR)
	$(OPENSSL) \
    pkcs12 \
    -export \
    -passin pass:$(CODE_SIGNING_CERTIFICATE_PASSWORD) \
    -passout pass:$(CODE_SIGNING_CERTIFICATE_PASSWORD) \
    -inkey $$< \
    $$(foreach crtFile,$$(filter %.crt,$$^),-in $$(crtFile)) \
    -out $$@

endef

# $(call encodeCertificatePfx, PfxFile)
encodeCertificatePfx = $(call encodeFile,,$1)

# $(call decodeCertificatePfx, PfxFile)
decodeCertificatePfx = $(call decodeFile,$1)

SIGNWITHSIGNTOOL ?= \
  $(SIGNTOOL) \
    sign \
    /f $(CODE_SIGNING_CERTIFICATE_PFX) \
    /p $(CODE_SIGNING_CERTIFICATE_PASSWORD) \
    /v \
    /tr http://timestamp.geotrust.com/tsa \
    /fd SHA1 \
    $(call winPath,$1)

# signtool.exe verify /v /a c:\signfiles\the_file_to_be_signed
#
# Double executable signing
# It is also possible to sign your binaries using SHA1 and SHA2
# to guarantee a maximal compatibility.
# However it can only work for binaries (.exe) and not for .msi installers.
# To do so, simply execute the two following commands:
# 
# signtool sign /f yourFile.pfx /p password /t "http://timestamp.verisign.com/scripts/timstamp.dll" /fd SHA1 "PATH_TO_EXECUTABLE"
# signtool sign /as /f yourFile.pfx /p password /tr "http://sha256timestamp.ws.symantec.com/sha256/timestamp" /td SHA256 /fd SHA256 "CHEMIN_VERS_VOTRE_EXECUTABLE"
# 
# The first command is used to sign the file using SHA1, the second one, SHA2.
# The SHA2 signature is set as default. The timestamping server for the SHA1 signature is using Microsoft's format.
# The example is valid for Symantec certificates. 
# If your want a RFC3161 compliant SHA1 signaure, you can use the following server :
# http://timestamp.geotrust.com/tsa 

SIGNWITHSIGNCODE = \
  $(SIGNCODEPWD) \
    -spc "$(call winPath,$(CODE_SIGNING_CERTIFICATE_SPC))" \
    -v "$(call winPath,$(CODE_SIGNING_CERTIFICATE_PVK))" \
    -j "mssipotf.dll" \
    -t "http://timestamp.verisign.com/scripts/timstamp.dll" \
    -p $(CODE_SIGNING_CERTIFICATE_PASSWORD) \
    "$(call winPath,$1)"

# $(call SIGN,fileForSigning)
SIGN = \
  $(if $(filter %.exe %.msi %.msm %.dll,$1), \
    $(call SIGNWITHSIGNTOOL,$1), \
    $(if $(filter %.ttf %.otf,$1), \
      $(call SIGNWITHSIGNCODE,$1) \
    ) \
  )

SIGNTARGET = $(call SIGN,$@)

# $(call SIGNFILES,files)
SIGNFILES = \
  set -e; \
  $(foreach file,$(1), \
    $(if $(strip $(call SIGN,$(file))),$(call SIGN,$(file));) \
  )

SIGNTESTWITHSIGNCODE = \
  $(SIGNTOOL) \
    verify \
    /pa \
    /all \
    /tw \
    /v \
    $1

SIGNTESTWITHCHKTRUST = \
  ( \
    cd $(dir $1);\
    $(CHKTRUST) -v -q $(notdir $1);\
  )

# $(call SIGNTEST,signedFile)
SIGNTEST = \
  $(if $(filter %.exe %.msi %.msm %.dll,$1), \
    $(call SIGNTESTWITHSIGNCODE,$1), \
    $(if $(filter %.ttf %.otf,$1), \
      $(call SIGNTESTWITHCHKTRUST,$1) \
    ) \
  )

SIGNTESTTARGET = $(call SIGNTEST,$@)

# $(call SIGNTESTS,signedFiles)
SIGNTESTS = \
  set -e; \
  $(foreach file,$(1), \
    $(if $(strip $(call SIGNTEST,$(file))),$(call SIGNTEST,$(file));) \
  )

endif
