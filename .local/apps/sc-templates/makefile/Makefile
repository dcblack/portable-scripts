#!make -f
#
# Project: {:NAME:}

SRCS := {:SRCS:}

# Do not edit below here
RULES:=$(firstword $(wildcard $(addsuffix /Makefile.defs,${SCC_APPS}/make ../../.. ../.. .. .)))
$(if ${RULES},$(info INFO: Including $(realpath ${RULES})),$(error Could not find Makefile.defs))
include ${RULES}
