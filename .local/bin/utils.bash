#!/usr/bin/env bash
#
# shellcheck disable=SC2312

cat >/dev/null <<'EOF' ;# Documentation begin_markdown {
SYNOPSIS
========

`utils.bash` - A collection of bash functions useful for scripting.
In particular, these are intended for use in scripts to build (fetch,
configure, compile and install) various apps and libraries (e.g., SystemC).
Note that a number of them have been moved into the `scripts/` directory
parallel to this directory to facilitate easier testing and maintenance.

Note: Capitalizing function names reduces collisions with scripts/executables.

| FUNCTION SYNTAX            | DESCRIPTION 
| :------------------------- | :---------- 
| GetBuildOpts "$0" "$@"     | Parses standard _build_ command-line inputs
| ShowBuildOpts              | Display options variables
| ConfirmBuildOpts || exit   | Asks user to confirm build locations
| SetupLogdir _BASENAME_     | Sets up the logfile directory
| Create_and_Cd DIR          | Creates directory and enters it
| GetSource_and_Cd DIR URL   | Downloads souce and enters directory
| Configure_tool [TYPE]      | Invokes cmake or autotools

USAGE
=====

Source this as follows inside your bash script:

```sh
function Realpath()
{
  /usr/bin/perl '-MCwd(abs_path)' -le '$p=abs_path(join(q( ),@ARGV));print $p if -e $p' "$*"
}
SCRIPT="$(Realpath "$0")"
SCRIPT="$(dirname "${SCRIPT}")/utils.bash"
if [[ -x "${SCRIPT}" ]]; then
  # shellcheck source=utils.bash
  source "${SCRIPT}" "$0"
else
  echo "Error: Missing ${SCRIPT}" 1>&2; exit 1
fi
SetupLogdir "$0"
```
} end_markdown
EOF

declare -a ARGV
export APPS
export ARGV
export BUILD_SOURCE_DOCUMENTATION
export CC
export CLEAN
export CLEANUP
export CMAKE_CXX_STANDARD
export CMAKE_INSTALL_PREFIX
export CXX
export DEBUG
export ERRORS
export GENERATOR
export GITROOT_DIR
export LOGDIR
export LOGFILE
export NOTREALLY
export SRC
export SYSTEMC_HOME
export SUFFIX
export TOOL_NAME
# shellcheck disable=SC2090
export TOOL_INFO
export TOOL_SRC
export TOOL_VERS
export TOOL_URL
export TOOL_PATCHES
export BUILD_DIR
export GENERATOR
export NOINSTALL
export UNINSTALL
export VERBOSITY
export WARNINGS

function Realpath ()
{
  /usr/bin/perl '-MCwd(abs_path)' -le '$p=abs_path(join(q( ),@ARGV));print $p if -e $p' "$*"
}
SCRIPTDIR="$(Realpath "$(dirname "$0")"/../scripts)"
if [[ ! -d "${SCRIPTDIR}" ]]; then
  printf "FATAL: Missing required directory '%s'\n" "${SCRIPTDIR}"
  crash
fi
# shellcheck disable=SC2250,SC1091
source "$SCRIPTDIR/Essential-IO"

PATCHDIR="$(Realpath "$(dirname "$0")"/../patches)"

#-------------------------------------------------------------------------------
function Require()
{ # FILE(S) to source
  local BINDIR SCPT REQD
  if [[ $# != 1 ]]; then
    echo "Fatal: Require only allows one argument" 1>&2; exit 1
  fi
  BINDIR="$(Realpath "$(dirname "$0")"/../bin)"
  SCPT="$1"; shift
  REQD="${BINDIR}/${SCPT}"
  if [[ -f "${REQD}" ]]; then
    # shellcheck disable=SC1090
    source "${REQD}"
  else
    echo "Fatal: Missing ${REQD}" 1>&2; exit 1
  fi
}

#-------------------------------------------------------------------------------
# Verify existance of tools in search path

function Needs()
{
  local I J X D P
  I=0 J=0
  for X in "$@"; do
    (( ++I ));
    for D in $(/usr/bin/perl -le 'print join(q{\n},split(/:/,$ENV{PATH}))'); do
      Report_debug "Testing  ${D}/${X}"
      P="$(Realpath "${D}/${X}")"
      if [[ -n "${P}" && -x "${P}" && ! -d "${P}" ]]; then
        (( ++J ));
        echo "${P}"
        break
      else
        P=""
      fi
    done
    if [[ -z "${P}" ]]; then Report_error "Missing ${X}"; fi
  done
  if [[ "${I}" == "${J}" ]]; then
    return 0
  else
    return 1
  fi
}

#-------------------------------------------------------------------------------

Setup-Color on

function ShowBuildOpts()
{
  Ruler -blu "Build Options"
  for (( i=0; i<${#ARGV[@]}; ++i )); do
    Report_debug "ARGV[${i}]='${ARGV[${i}]}'"
  done
  ShowVars \
    APPS \
    BUILD_SOURCE_DOCUMENTATION \
    CLEAN \
    CLEANUP \
    CMAKE_CXX_STANDARD \
    CMAKE_INSTALL_PREFIX \
    CC \
    CXX \
    DEBUG \
    GITROOT_DIR \
    LOGDIR \
    LOGFILE \
    NOTREALLY \
    SRC \
    SYSTEMC_HOME \
    SUFFIX \
    TOOL_NAME \
    TOOL_INFO \
    TOOL_VERS \
    TOOL_URL \
    TOOL_PATCHES \
    BUILD_DIR \
    GENERATOR \
    NOINSTALL \
    UNINSTALL \
    VERBOSITY \
    ;
  Ruler -blu
}

function ConfirmBuildOpts()
{
  ShowBuildOpts
  while true; do
    printf "Confirm above options (Y/n)? "
    read -r REPLY
    case "${REPLY}" in
      y|Y|yes) return 0 ;;
      n|N|no) return 1 ;;
      *) REPLY=""; echo "Must reply with 'y' or 'n'" ;;
    esac
  done
}

function GetBuildOpts()
{

# Establishes options for building
#
#-------------------------------------------------------------------------------
# The following is formatted for use with -help
#|
#|NAME
#|----
#|
#|  $0 - helper script for build scripts
#|
#|SYNOPSIS
#|--------
#|
#|  GetBuildOpts() "${0}" "$@"
#|
#|DESCRIPTION
#|-----------
#|
#|  Read command-line options and sets various environment variables.
#|
#|PARSED COMMAND-LINE OPTIONS
#|---------------------------
#|
#|  Option             |  Alternative      | Description
#|  ------             |  ------------     | -----------
#|  --build-dir=DIR    |  -bd DIR          | source subdirectory to build in
#|  --cc=C_COMPILER    |  CC=C_COMPILER    | chooses C compiler executable
#|  --clang            |                   | quick --cc=clang --cxx=clang++
#|  --clean            |  -clean           | reinstall source
#|  --cleanup          |  -cleanup         | remove source after installation
#|  --cxx=CPP_COMPILER |  CXX=CPP_COMPILER | chooses C++ compiler executable
#|  --debug            |  -d               | developer use
#|  --default          |                   | quick -i=$HOME/.local -src=$HOME/.local/src
#|  --gcc              |                   | quick --cc=gcc --cxx=g++
#|  --generator=TYPE   |  -gen TYPE        | cmake or autotools
#|  --home             |                   | quick -i $HOME -s $HOME/src
#|  --info=TEXT        |  -info TEXT       | choose installation directory
#|  --install=DIR      |  -i DIR           | choose installation directory
#|  --nogetbuildopts   |  -na              | don't automatically GetBuildOpts
#|  --notreally        |  -n               | don't execute, just show possibilities
#|  --no-install       |  -no-install      | do not install
#|  --no-patch         |  -no-patch        | do not patch 
#|  --patch[=name]     |  -patch [name]    | apply patches
#|  --src=DIR          |  -s DIR           | choose source directory
#|  --std=N            |  -std=N           | set make C++ compiler version where N={98,11,14,17,20,...}
#|  --systemc=DIR      |  -sc              | reference SystemC installation
#|  --suffix=TEXT      |  -suf TEXT        | set suffix for installation name
#|  --tool=NAME        |  -tool NAME       | set the desired tool name for tool source
#|  --uninstall        |  -rm              | remove if possible -- not always supported
#|  --url=URL          |  -url URL         | set the URL for the source code
#|  --verbose          |  -v               | echo more information (may be repeated)
#|  --version=X.Y.Z    |  -vers X.Y.Z      | set the desired tool version
#|  --quiet            |  -q               | echo less information (may be repeated)
#|
#|OUTPUTS
#|-------
#|
#| Below are some of the environment variables are used by scripts:
#|
#| - $APPS
#| - $CC
#| - $CLEAN
#| - $CLEANUP
#| - $CMAKE_CXX_STANDARD {98|03|11|14|17|20}
#| - $CMAKE_INSTALL_PREFIX
#| - $CXX
#| - $DEBUG
#| - $ERRORS integer
#| - $GITROOT_DIR
#| - $LOGDIR
#| - $LOGFILE
#| - $NOTREALLY
#| - $NOINSTALL
#| - $SRC directory
#| - $SYSTEMC_HOME
#| - $SUFFIX
#| - $TOOL_NAME
#| - $TOOL_INFO
#| - $TOOL_PATCHES
#| - $TOOL_SRC
#| - $TOOL_URL
#| - $TOOL_VERS
#| - $BUILD_DIR
#| - $GENERATOR {cmake|autotools}
#| - $TOOL_URL
#| - $UNINSTALL
#| - $VERBOSITY integer
#| - $WARNINGS integer
#|
#| Use -devhelp for internal documentation.
#|
#|LICENSE
#|-------
#|
#| Apache 2.0

  if [[ "$2" =~ ^-{1,2}(na|nogetbuildopts)$ ]]; then return; fi

  # Grab program name
  local SCRIPT
  # shellcheck disable=SC2034
  SCRIPT="$1"
  shift

  # Defaults
  #-------------------------------------------------------------------------------
  CMAKE_CXX_STANDARD=17 # <---------- VERSION OF C++ YOUR COMPILER SUPPORTS
  if [[ "${CXX}" == "" ]]; then
    if [[ "$(command -v clang++||true)" != "" ]]; then
      CXX=clang++
      CC=clang
    elif [[ "$(command -v g++||true)" != "" ]]; then
      CXX=g++
      CC=gcc
    else
      Report_fatal "Unable to determine C++ compiler"
    fi
  fi
  if git rev-parse --show-toplevel 2>/dev/null 1>/dev/null; then
    GITROOT_DIR="$(git rev-parse --show-toplevel)"
  else
    Report_warning "Not inside a git controlled area"
    GITROOT_DIR="Unknown"
  fi

  #-------------------------------------------------------------------------------
  # Scan command-line for options
  #-------------------------------------------------------------------------------
  while [[ $# != 0 ]]; do
    case "$1" in
    -devhelp|--devhelp)
      HelpText -md "${0}";
      exit 0
      ;;
    -h|-help)
      HelpText "${0}";
      exit 0
      ;;
    -n|--not-really|--notreally)
      NOTREALLY="-n"
      shift
      ;;
    -no-install|--no-install|--noinstall)
      NOINSTALL="-n"
      shift
      ;;
    -no-patch|--no-patch|--nopatch)
      NOPATCH=1
      shift
      ;;
    --build-dir=*|-bd)
      if [[ "$1" != '-bd' ]]; then
        BUILD_DIR="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        BUILD_DIR="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    --cc=*|CC=*)
      CC="${1//*=}"
      if [[ "${CC}" =~ .*gcc ]];then
        CXX=g++
      elif [[ "${CC}" =~ .*clang++ ]]; then
        CXX=clang++
      fi
      shift
      ;;
    --clang)
      CC=clang
      CXX=clang++
      shift
      ;;
    --clean|-clean)
      CLEAN=1;
      shift;
      ;;
    --cleanup|-cleanup)
      CLEANUP=1;
      shift;
      ;;
    --cxx=*|CXX=*)
      CXX="${1//*=}"
      if [[ "${CXX}" == g++ ]]; then
        CC=gcc
      elif [[ "${CXX}" == clang++ ]]; then
        CC=clang
      fi
      shift;
      ;;
    -d|-debug|--debug)
      DEBUG=1;
      shift;
      ;;
    --default)
      APPS="${HOME}.local/apps"
      SRC="${HOME}/.local/src"
      shift
      ;;
    --doxy)
      BUILD_SOURCE_DOCUMENTATION=on
      ;;
    --gcc)
      CC=gcc
      CXX=g++
      shift
      ;;
    --generator=*|-gen)
      if [[ "$1" != '-gen' ]]; then
        GENERATOR="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        GENERATOR="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    --info=*|-info)
      if [[ "$1" != '-info' ]]; then
        TOOL_INFO="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        TOOL_INFO="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    -i|--install=*|--apps=)
      if [[ "$1" != '-i' ]]; then
        APPS="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        APPS="$2"
        shift
      else
        Report_fatal "Need directory argument for $1"
      fi
      shift
      ;;
    --home)
      APPS="${HOME}"
      SRC="${HOME}/src"
      shift
      ;;
    -pref|--prefix=*)
      if [[ "$1" != '-pref' ]]; then
        CMAKE_INSTALL_PREFIX="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        CMAKE_INSTALL_PREFIX="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift
      ;;
    --root-dir=*|-rd)
      if [[ "$1" != '-rd' ]]; then
        GITROOT_DIR="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        GITROOT_DIR="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    -patch|--patch=*)
      PATCH=
      if [[ "$1" != '-patch' ]]; then
        PATCH="${1//*=}"
      elif [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
        PATCH="$2"
        shift
      else
        PATCH="${TOOL_SRC}"
      fi
      if [[ -n "${PATCH}" ]]; then
        PATCH="${PATCHDIR}/${PATCH}"
      fi
      if [[ ! "${PATCH}" =~ [.]patch(es)?$ ]]; then
        PATCH="${PATCH}.patches"
      fi
      if [[ -r "${PATCH}" ]]; then
        TOOL_PATCHES="${PATCH}"
      else
        Report_fatal "Patch '${PATCH}' does not exist"
      fi
      shift
      ;;
    -s|--src=*)
      if [[ "$1" != '-s' ]]; then
        SRC="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SRC="$2"
        shift
      else
        Report_fatal "Need directory argument for $1"
      fi
      shift
      ;;
    --std=*|-std=*)
      CMAKE_CXX_STANDARD="${1//*=}"
      shift;
      ;;
    --systemc=*|-sc)
      if [[ "$1" != '-sc' ]]; then
        SYSTEMC_HOME="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SYSTEMC_HOME="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    --suffix=*|-suf)
      if [[ "$1" != '-suf' ]]; then
        SUFFIX="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SUFFIX="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    --tool=*|-tool)
      if [[ "$1" != '-tool' ]]; then
        TOOL_NAME="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        TOOL_NAME="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    --uninstall|-rm)
      CLEANUP=1;
      shift;
      ;;
    --url=*|-url)
      TOOL_URL="${1//*=}"
      shift;
      ;;
    --version=*|-vers)
      if [[ "$1" != '-vers' ]]; then
        TOOL_VERS="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        TOOL_VERS="$2"
        shift
      else
        Report_fatal "Need argument for $1"
      fi
      shift;
      ;;
    *)
      ARGV[${#ARGV[@]}]="$1"
      shift
      ;;
    esac
  done

  #-------------------------------------------------------------------------------
  # Defaults if not set
  if [[ -z "${APPS}" || ! -d "${APPS}" ]]; then
    APPS="${HOME}/.local/apps"
  fi
  if [[ -z "${SYSTEMC_HOME}" ]]; then
    SYSTEMC_HOME="${APPS}/systemc"
  fi
  if [[ -z "${CMAKE_INSTALL_PREFIX}" ]]; then
    CMAKE_INSTALL_PREFIX="${APPS}"
  fi
  if [[ -z "${GENERATOR}" ]]; then
    GENERATOR=cmake
  fi
  if [[ -z "${BUILD_DIR}" ]]; then
    BUILD_DIR="build-${GENERATOR}-$(basename "${CC}")"
  fi
  if [[ -z "${BUILD_SOURCE_DOCUMENTATION}" ]]; then
    BUILD_SOURCE_DOCUMENTATION="off"
  fi

  #-------------------------------------------------------------------------------
  # Test some assumptions
  if [[ "${GENERATOR}" =~ (cmake|autotools) ]]; then
    Comment all is ok
  else
    Report_error "GENERATOR must be one of 'cmake' or 'autotools'"
  fi

  #-------------------------------------------------------------------------------
  # Setup apps directory
  mkdir -p "${APPS}" || Report_fatal "Failed to find/create ${APPS} directory"

  #-------------------------------------------------------------------------------
  Report_info "Setup source directory"
  if [[ -z "${SRC}" || ! -d "${SRC}" ]]; then
    if [[ "${APPS}" == '/apps' ]]; then
      SRC="${APPS}/src"
    elif [[ "${APPS}" != '' ]]; then
      SRC="$(dirname "${APPS}")/src"
    elif [[ "${HOME}" == "$(pwd||true)" ]]; then
      SRC="${HOME}/.local/src"
    else
      SRC="$(pwd)/src"
    fi
  fi
  mkdir -p "${SRC}" || Report_fatal "Failed to find/create ${SRC} directory"

  cd "${SRC}" || Report_fatal "Unable to change into source directory"

  if [[ -n "${DEBUG}" && "${DEBUG}" != 0 ]]; then
    ShowBuildOpts
  fi

}

function SetupLogdir()
{
  local NONE
  NONE="$(_C none)"
  # Creates log directory and sets initial LOGFILE
  LOGDIR="${HOME}/logs"
  mkdir -p "${LOGDIR}"
  case $# in
    1)
      Logfile "$(basename "$1")"
      ;;
    0)
      if [[ -z "${LOGFILE}" ]]; then
        echo "$(_C red)Warning:${NONE} Did not specify LOGFILE${NONE}"
      else
        Logfile
      fi
      ;;
    *)
      echo "$(_C red)Error: Too many parameters specified${NONE}"
      ;;
  esac
}

# Make directory and enter
function Create_and_Cd()
{
  Assert $# = 1
  _do mkdir -p "${1}" || Report_fatal "Unable to create ${1}"
  _do cd "${1}" || Report_fatal "Unable to enter ${1} directory"
}

# Download and enter directory and patch
function GetSource_and_Cd()
{
  Assert $# = 2
  if [[ -n "${CLEAN}" && "${CLEAN}" == 1 ]]; then
    _do rm -fr "${1}"
  fi
  if [[ -d "${1}/.git" ]]; then
    _do git pull
  else
    if [[ -d "${1}/." ]]; then
      _do mkdir -p "${1}-save"
      _do rsync -a "${1}/" "${1}-save/"
      _do rm -fr "${1}" 
    fi
    _do git clone "${2}" "${1}" || Report_fatal "Unable to clone into ${1}"
  fi
  cd "${1}" || Report_fatal "Unable to enter ${1}"
  if [[ -n "${TOOL_VERS}" ]]; then
    _do git  checkout "${TOOL_VERS}"
  fi
  if [[ -n "${TOOL_PATCHES}" ]]; then
    _do git  am --empty=drop "${TOOL_PATCHES}"
  fi
}

# Arguments are optional
# shellcheck disable=SC2120
function Configure_tool()
{
  Report_info -grn "Configuring ${TOOL_NAME}"
  if [[ $# == 1 ]]; then # option generator
    GENERATOR="$1"
    shift
  else
    Assert -n "${GENERATOR}"
  fi
  Assert $# = 0
  case "${GENERATOR}" in
    cmake)
      _do rm -fr "${BUILD_DIR}"
      local HOST_OS TARGET_ARCH APPLE
      HOST_OS="$(uname -s)"
      TARGET_ARCH="$(uname -m)"
      # Handle Apple Silicon
      APPLE=
      if [[ "${HOST_OS}" == Darwin ]]; then
        APPLE="-DCMAKE_APPLE_SILICON_PROCESSOR=${TARGET_ARCH}"
      fi
      _do cmake -B "${BUILD_DIR}"\
          -DCMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}"\
          -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD}"\
          -DBUILD_SOURCE_DOCUMENTATION="${BUILD_SOURCE_DOCUMENTATION}"\
          "${APPLE}"
      ;;
    autotools)
      reconfigure
      _do mkdir -p "${BUILD_DIR}"
      _do cd "${BUILD_DIR}" || Report_fatal "Unable to enter ${BUILD_DIR}"
      _do env CXXFLAGS="-std=c++${CMAKE_CXX_STANDARD} -I/opt/local/include -I${SYSTEMC_HOME}/include"\
          ../configure --prefix="${SYSTEMC_HOME}"
      ;;
    *)
      Report_error "Unknown generator '${GENERATOR}'"
      ;;
  esac
}
alias Generate=Configure_tool
 
# Arguments are optional
# shellcheck disable=SC2120
function Compile_tool()
{
  Report_info -grn "Compiling ${TOOL_NAME}"
  case "${GENERATOR}" in
    cmake)
      _do cmake --build "${BUILD_DIR}"
      ;;
    autotools)
      _do cd "${BUILD_DIR}" || Report_fatal "Unable to enter ${BUILD_DIR}"
      _do make
      ;;
    *)
      Report_error "Unknown generator '${GENERATOR}'"
      ;;
  esac
}

function Install_tool()
{
  Report_info -grn "Installing ${TOOL_NAME} to final location"
  case "${GENERATOR}" in
    cmake)
      _do cmake --install "${BUILD_DIR}"
      ;;
    autotools)
      _do make install
      ;;
    *)
      Report_error "Unknown generator '${GENERATOR}'"
      ;;
  esac
}

function Cleanup()
{
  Assert $# = 1
  if [[ -n "${CLEANUP}" && "${CLEANUP}" == 1 ]]; then
    cd "${SRC}" || Report_fatal "Unable to enter source directory"
    rm -fr "${1}"
  fi
}

function Main()
{
  Assert "${BASH_VERSINFO[0]}" -ge 5
  if [[ $# != 0 ]]; then
    GetBuildOpts "$0" "$@"
    if [[ ${#ARGV[@]} -gt 0 ]]; then
      if [[ -n "${DEBUG}" ]]; then echo "${ARGV[@]}"; fi
    fi
  fi
}

Main "$@"

# vim:nospell
