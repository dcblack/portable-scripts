#!/bin/gmake -f
#
#$Info: {:NAME:} - {:DESCRIPTION:}. $

SHELL := bash
GREP  := $(shell command -v grep)
PERL  := $(shell command -v perl)

THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
PHONIES := $(shell ${PERL} -lane 'print $$1 if m{^([a-zA-Z][-a-zA-Z0-9_]*):[^=]*$$};' ${THIS_MAKEFILE})
.PHONY: ${PHONIES}

#|------------------------------------------------------------------------------
#|
#| Description
#| -----------
#|
#| Top-level GNUmakefile to support automation of simple tasks.
#|
#| TARGET  | DESCRIPTION
#| ------  | -----------
#|
#.______________________________________________________________________________

#| * help - display documentation (safe)
help: # default target
	@${GREP} '^#|' ${THIS_MAKEFILE} | ${GREP} -v ' x ' | cut -c 3-

#.______________________________________________________________________________
#| * {:PHONY} - {:DESCRIPTION:}
{:PHONY:}:
	{:ACTION:}

#|------------------------------------------------------------------------------
# vim:syntax=make:nospell
# The end
