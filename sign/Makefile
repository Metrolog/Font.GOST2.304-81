###
### GNU make Makefile for update .pvk and .spc files from .pfx
###

.DEFAULT_GOAL		:= all

.PHONY: all
all: pvk spc

.DELETE_ON_ERROR:;

OPENSSL				?= "%ProgramFiles(x86)%/OpenSSL/bin/openssl"
SIGNCERTIFICATE		?= sign

%_key.pem: %.pfx
	$(OPENSSL) pkcs12 -in $< -nocerts -nodes -out $@

%.pvk: %_key.pem
	$(OPENSSL) rsa -in $< -outform PVK -pvk-strong -out $@

%_cert.pem: %.pfx
	$(OPENSSL) pkcs12 -in $< -nokeys -out $@

%.spc: %_cert.pem
	$(OPENSSL) crl2pkcs7 -nocrl -certfile $< -outform DER -out $@

.PHONY: pvk
pvk: $(SIGNCERTIFICATE).pvk

.PHONY: spc
spc: $(SIGNCERTIFICATE).spc

# clean projects

.PHONY: clean
clean:
	-rm -f *.pem
	-rm -f *.pvk
	-rm -f *.spc
