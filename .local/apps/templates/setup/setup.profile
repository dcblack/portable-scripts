#!/usr/bin/env bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if [[ ${SOURCED} == 0 ]]; then
  echo "Don't run $0, source it" >&2
  exit 1
fi

export SETUP_PATH PROJECT_DIR

# NOTES
# - PROJECT_NAME and SETUP_PATH are for debug purposes.
# - PROJECT_DIR is used to locate the top directory
function Realpath()
{
  if [[ $# == 0 ]]; then set - .; fi
  # shellcheck disable=SC2016
  local PERLSCRIPT='$p=abs_path(join(q( ),@ARGV));print $p if -e $p'
  /usr/bin/env perl '-MCwd(abs_path)' -le "${PERLSCRIPT}" "$*"
}

function Project_setup()
{
  # @brief does the real work of setup
  if [[ "$2" == "-v" ]]; then
    echo "Sourcing $1"
  fi

  export ACTION
  if [[ "$2" =~ --rm || "${ACTION}" == "rm" ]]; then
    ACTION="rm"
    PROJECT_NAME="$(basename "${PROJECT_DIR}")"
    echo "$1: ${PROJECT_NAME} environment removed"
  else
    ACTION="add"
    PROJECT_DIR="$(dirname "${SETUP_PATH}")"
    PROJECT_NAME="$(basename "${PROJECT_DIR}")"

    export ACTION PROJECT_NAME SETUP_PATH PROJECT_DIR
    echo "$1: ${PROJECT_NAME} environment set up"
  fi
}

function Check_environment()
{
  # @brief test for a few critical bits
  # - Only invoked if -v is passed when sourcing
  echo "Nothing to check"
}
# Works in ZSH and BASH
# shellcheck disable=SC2154
if [[ -n "${ZSH_VERSION}" ]]; then
  SETUP_PATH="$(Realpath "$0")"
  Project_setup "${SETUP_PATH}" "$@"
else
  SETUP_PATH="$(Realpath "${BASH_SOURCE[0]}")"
  Project_setup "${SETUP_PATH}" "$@"
fi
# shellcheck disable=SC2149
alias setup="source '${SETUP_PATH}'"

if [[ "$1" == "-v" ]]; then
  ( Check_environment )
  Summary "${SETUP_PATH}"
fi

# vim:nospell
