#!make -f
#
# Project: {:NAME:}

#VERBOSE := 1
MODULE   := {:NAME:}
SRCS     := {:SRCS:}
#ARGS    := args...
#STDIN   := file.in
#STDOUT  := file.out
#STDERR  := file.err
#STDLOG  := file.log

# Do not edit below here
RULES:=$(firstword $(wildcard $(addsuffix /Makefile.defs,. .. ../.. ../../.. ../../../.. ${SCC_APPS}/make)))
$(if ${RULES},$(info INFO: Including $(realpath ${RULES})),$(error Could not find Makefile.defs))
include ${RULES}
