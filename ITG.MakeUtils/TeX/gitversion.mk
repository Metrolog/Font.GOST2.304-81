ifndef MAKE_TEX_GITVERSION_DIR
MAKE_TEX_GITVERSION_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(realpath $(MAKE_TEX_GITVERSION_DIR)/..)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)
include $(realpath $(ITG_MAKEUTILS_DIR)/gitversion.mk)

%/version.tex %/version.dtx: $(REPOVERSION)
	$(info Generate latex version file "$@"...)
	$(MAKETARGETDIR)
	@git log -1 --date=format:%Y/%m/%d --format="format:\
%%\iffalse%n\
%%<*version>%n\
%%\fi%n\
\def\GITCommitterName{%cn}%n\
\def\GITCommitterEmail{%ce}%n\
\def\GITCommitterDate{%cd}%n\
\def\ExplFileDate{%ad}%n\
\def\ExplFileVersion{$(FULLVERSION)}%n\
\def\ExplFileAuthor{%an}%n\
\def\ExplFileAuthorEmail{%ae}%n\
%%\iffalse%n\
%%</version>%n\
%%\fi%n\
" > $@
	touch $@

endif