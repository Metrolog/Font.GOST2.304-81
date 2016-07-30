###
### GNU make Makefile for build GOST 2.304-81 projects
###

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/gitversion.mk

# sub projects

ifeq ($(OS),Windows_NT)

$(eval $(call useSubProject,sign,sign,cert-prepare pvk spc))

endif

$(eval $(call useSubProject,fonts,fonts,ttf ttc woff otf pstype0 pstype1))
$(eval $(call useSubProject,tex,tex,unpack doc ctan))

ifeq ($(OS),Windows_NT)

$(eval $(call useSubProject,msm,setup/msm))
$(eval $(call useSubProject,msi,setup/msi))
$(eval $(call useSubProject,choco.fonts.install,setup/chocolatey/font.gost2.304-81.install))

endif
