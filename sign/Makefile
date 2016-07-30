###
### GNU make Makefile for update .pvk and .spc files from .pfx
###

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/signing/sign.mk

CODE_SIGNING_CERTIFICATE_DIR = certificate
CODE_SIGNING_CERTIFICATE := $(CODE_SIGNING_CERTIFICATE_DIR)/cert.pfx
CODE_SIGNING_CERTIFICATE_PFX := $(basename $(CODE_SIGNING_CERTIFICATE)).pfx
CODE_SIGNING_CERTIFICATE_PVK := $(basename $(CODE_SIGNING_CERTIFICATE)).pvk
CODE_SIGNING_CERTIFICATE_PVK_PEM := $(basename $(CODE_SIGNING_CERTIFICATE)).key.pem
CODE_SIGNING_CERTIFICATE_SPC := $(basename $(CODE_SIGNING_CERTIFICATE)).spc
CODE_SIGNING_CERTIFICATE_SPC_PEM := $(basename $(CODE_SIGNING_CERTIFICATE)).cert.pem

ifdef CODE_SIGNING_PRIVATE_KEY

%_key.pem:
	$(file > $@,-----BEGIN PRIVATE KEY-----)
	$(file >> $@,$(CODE_SIGNING_PRIVATE_KEY))
	$(file >> $@,-----END PRIVATE KEY-----)
%_cert.pem:
	$(file > $@,$(CODE_SIGNING_PRIVATE_KEY))

else

$(eval $(call exportCodeSigningCertificate,$(CODE_SIGNING_CERTIFICATE)))
.PHONY: cert-prepare
cert-prepare: $(CODE_SIGNING_CERTIFICATE)

$(eval $(call exportCertificateKeyFromPfx2Pem,$(CODE_SIGNING_CERTIFICATE_PVK_PEM),$(CODE_SIGNING_CERTIFICATE_PFX)))
$(eval $(call convertCertificateKeyPem2Pvk,$(CODE_SIGNING_CERTIFICATE_PVK),$(CODE_SIGNING_CERTIFICATE_PVK_PEM)))
.PHONY: pvk
pvk: $(CODE_SIGNING_CERTIFICATE_PVK)

$(eval $(call exportCertificateFromPfx2Pem,$(CODE_SIGNING_CERTIFICATE_SPC_PEM),$(CODE_SIGNING_CERTIFICATE_PFX)))
$(eval $(call convertCertificatePem2Spc,$(CODE_SIGNING_CERTIFICATE_SPC),$(CODE_SIGNING_CERTIFICATE_SPC_PEM)))
.PHONY: spc
spc: $(CODE_SIGNING_CERTIFICATE_SPC)

endif

clean::
	rm -rf $(CODE_SIGNING_CERTIFICATE_DIR)
