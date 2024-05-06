#!gmake -f

SHELL := bash
GREP  := $(shell command -v grep)
PERL  := $(shell command -v perl)

THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
PHONIES := $(shell ${PERL} -lane 'print $$1 if m{^([a-zA-Z][-a-zA-Z0-9_]*):[^=]*$$};' ${THIS_MAKEFILE})

#|------------------------------------------------------------------------------
#|
#| Description
#| -----------
#|
#| This top-level GNUmakefile provides support for developers to automate
#| simple tasks.
#|
#| Targets
#| -------
#|
#.______________________________________________________________________________
#| * help - display documentation (safe)
PERLHELP:='print unless m{ x } or ( m{ [*] } and not m{safe} )'
help: # default target
	@${GREP} '^#|' ${THIS_MAKEFILE} | ${GREP} -v ' x ' | cut -c 3-

.PHONY: {:PHONY:}

export AUTH_SERVICE="127.0.0.0"
#.______________________________________________________________________________
#| * {:PHONY} - {:DESCRIPTION:}
{:PHONY:}:
	{:ACTION:}
#.______________________________________________________________________________
#| * {:PHONY} - {:DESCRIPTION:}
{:PHONY:}:
	{:ACTION:}

#|------------------------------------------------------------------------------
# vim:syntax=make:nospell
# The end
