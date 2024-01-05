#!/usr/bin/env bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if [[ ${SOURCED} == 0 ]]; then
  echo "Don't run $0, source it" >&2
  exit 1
fi

export SYSTEMC_HOME LD_LIBRARY_PATH DYLD_LIBRARY_PATH

# NOTES
# - APPS is occasionally used to reference tools installed outside the project.
#   It is also known as the base "installation directory".
# - PROJECT_NAME and SETUP_PATH are for debug purposes.
# - SYSTEMC_HOME refers to the installation location of SystemC - *NOT* the source
#   This typically exists under $APPS.
# - LD_LIBRARY_PATH and DLYD_LIBRARY_PATH are used for dynamically linked executables
# - PROJECT_DIR is used to locate the extern and include directories.
#
# - Key directories and files include:
# $PROJECT_DIR/
#   ├── CMakeLists.txt -- top-level used for regression testing
#   ├── GNUmakefile -- used by instructors for maintenance
#   ├── INSTALLATION.md
#   ├── LICENSE
#   ├── Makefile.defs
#   ├── VERSION.txt
#   ├── cmake/ -- CMake scripts
#   ├── extern/ -- empty, used for certain external 3rd party installs
#   │   ├── ABOUT.md
#   │   └── bin/ -- useful for building and running
#   ├── include/ -- headers shared amoung exercises
#   └── setup.profile

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

  APPS="${HOME}/.local/apps"
  local OPT FLAG=0
  for OPT in "$@"; do
    case "${OPT}" in
      --install-dir)
        FLAG=1
        ;;
      -*) 
        ;;
      *) 
        if [[ ${FLAG} == 1 ]]; then
          APPS="${OPT}"
          FLAG=0
        fi
        ;;
    esac
  done
  export ACTION
  if [[ "$2" =~ --rm || "${ACTION}" == "rm" ]]; then
    ACTION="rm"
    Remove_path PATH "${PROJECT_BIN}"
  else
    ACTION="add"
    SETUP_PATH="$(Realpath "$1")"
    PROJECT_DIR="$(dirname "${SETUP_PATH}")"
    PROJECT_NAME="$(basename "${PROJECT_DIR}")"
    PROJECT_BIN="${PROJECT_DIR}/extern/bin"
    # shellcheck disable=SC1091
    source "${PROJECT_DIR}/extern/scripts/Essential-IO"
    source "${PROJECT_DIR}/extern/scripts/Essential-manip"

    SYSTEMC_HOME="${APPS}/systemc"
    LD_LIBRARY_PATH="${HOME}/.local/apps/systemc/lib"
    DYLD_LIBRARY_PATH="${HOME}/.local/apps/systemc/lib"
    Prepend_path PATH "${PROJECT_BIN}"

    if [[ ! -d "${SETUP_PATH}/.git" ]]; then
      _do git init "${SETUP_PATH}/.git"
      _do git -C "${SETUP_PATH}" add .
      _do git -C "${SETUP_PATH}" commit -m 'initial'
    fi

    export ACTION APPS PROJECT_NAME SETUP_PATH PROJECT_DIR
    export SYSTEMC_HOME LD_LIBRARY_PATH DYLD_LIBRARY_PATH
    echo "$1: ${PROJECT_NAME} environment set up"
  fi
}

function Check_version()
{
  # @brief return the version of tool
  local version
  if command -v "$1" 1>/dev/null 2>&1; then
    echo -n "$1 "
    version="$1 $(command "$1" --version)"
    # shellcheck disable=SC2312
    perl -e 'printf qq{%s\n},$& if "@ARGV" =~ m{\b[1-9]+([.][0-9]+)+}' "${version}"
  fi
}

function Check_environment()
{
  # @brief test for a few critical bits
  # - Only invoked if -v is passed when sourcing
  export PROJECT_DIR
  cd "${PROJECT_DIR}" 2>/dev/null || return 1
  Reset-errors
  local dir
  for dir in cmake extern; do
    if [[ ! -d "${PROJECT_DIR}/${dir}" ]]; then
      Report_warning "Missing ${dir}/ directory -- suspicious"
    fi
  done
  # What tools are available
  local tool version
  for tool in make ninja cmake ctest; do
    Check_version "${tool}"
  done
  if [[ ! -d "${SYSTEMC_HOME}" ]]; then
    Report_warning "SYSTEMC_HOME does not point to a directory!?"
  else
    if [[ ! -d "${SYSTEMC_HOME}/include" ]]; then
      Report_warning "Missing SYSTEMC_HOME/include!?"
    fi
    if [[ ! -d "${SYSTEMC_HOME}/lib" ]]; then
      Report_warning "Missing SYSTEMC_HOME/lib!?"
    fi
  fi
}

if [[ "$0" =~ sh$ ]]; then
  Project_setup "setup.profile" "$@"
else
  Project_setup "$0" "$@"
fi
if [[ "$1" == "-v" ]]; then
  ( Check_environment )
  Summary setup.profile
fi

# vim:nospell
