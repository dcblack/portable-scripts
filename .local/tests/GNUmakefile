#!make -f

#|------------------------------------------------------------------------------
#|
#| Description
#| -----------
#|
#| This GNUmakefile verifies scripts (primarily bash) function correctly.
#|
#|------------------------------------------------------------------------------

# Find path to THIS file
THIS_MAKEFILE := $(realpath $(lastword ${MAKEFILE_LIST}))
PHONIES := $(shell perl -lane 'print $$1 if m{^([a-zA-Z][-a-zA-Z0-9_]*):[^=]*$$};' ${THIS_MAKEFILE})

# $(call Findbin,PGM) will return the full path to a program preferring ./bin or ../bin
Findbin=$(firstword $(wildcard $(addsuffix /$1,$(subst :, ,./bin:../bin:${MAKEFILE_BINDIR}:${PATH}))))

SHELL=$(call Findbin,bash)
CHECK=$(call Findbin,shellcheck)

.DEFAULT_GOAL := all-short
.PHONY: $(PHONIES)

#| * help - display documentation
help:
	@grep '^#|' ${THIS_MAKEFILE} | cut -c 3-

all: all-short all-long

# Quick tests
all-short: 

# Long running tests (i.e., installation of large tools that require long compilations)
all-long:


#TAF!
