ifndef MAKE_TEX_VERSION_GIT_DIR
MAKE_TEX_VERSION_GIT_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(MAKE_TEX_VERSION_GIT_DIR)../common.mk

GITVERSION := $(lastword $(shell git --version))

GIT_BRANCH          := $(shell git symbolic-ref HEAD)
VCSTURD             := $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
export VERSION      := $(shell git symbolic-ref --short HEAD)
export FULLVERSION  := $(VERSION).$(shell git rev-list --count --first-parent HEAD).$(shell git rev-list --count HEAD)
export MAJORVERSION := $(firstword $(subst ., ,$(VERSION)))
export MINORVERSION := $(wordlist 2,2,$(subst ., ,$(VERSION)))

%/version.tex %/version.dtx: .git/logs/HEAD
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
\def\ExplFileVersion{$(VERSION)}%n\
\def\ExplFileAuthor{%an}%n\
\def\ExplFileAuthorEmail{%ae}%n\
%%\iffalse%n\
%%</version>%n\
%%\fi%n\
" > $@

endif