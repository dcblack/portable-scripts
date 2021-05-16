#!/bin/bash
#
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
#|  $0 -devhelp
#|  Require $0
#|  GetBuildOpts() "${0}" "$@"
#|
#|DESCRIPTION
#|-----------
#|
#|  Downloads, unpacks, builds and installs the latest or specified version of fmtlib.
#|
#|PARSED COMMAND-LINE OPTIONS
#|---------------------------
#|
#|  Option             |  Alternative      | Description
#|  ------             |  ------------     | -----------
#|  --cc=C_COMPILER    |  CC=C_COMPILER    | chooses C compiler executable
#|  --clang            |                   | quick --cc=clang --cxx=clang++
#|  --cxx=CPP_COMPILER |  CXX=CPP_COMPILER | chooses C++ compiler executable
#|  --debug            |                   | developer use
#|  --default          |                   | quick -i=$HOME/.local -src=$HOME/.local/src
#|  --gcc              |                   | quick --cc=gcc --cxx=g++
#|  --home             |                   | quick -i $HOME -s $HOME/src
#|  --install=DIR      |  -i DIR           | choose installation directory
#|  --src=DIR          |  -s DIR           | choose source directory
#|  --std=N            |  -std=N           | set make C++ compiler version where N={98,11,14,17,20,...}
#|  --suffix=TEXT      |  -suf TEXT        | set suffix for installation name
#|
#|OUTPUTS
#|-------
#|
#| The following environment variables are used by scripts
#|
#| - $SRC
#| - $APPS
#| - $CMAKE_CXX_STANDARD
#| - $CC
#| - $CXX
#| - $DEBUG
#| - $SUFFIX

function GetBuildOpts() {

  # Grab program name
  local SCRIPT
  SCRIPT="$1"
  shift

  # Defaults
  #-------------------------------------------------------------------------------
  CMAKE_CXX_STANDARD=17 # <---------- VERSION OF C++ YOUR COMPILER SUPPORTS
  export CMAKE_CXX_STANDARD
  if [[ "${CXX}" == "" ]]; then
    if [[ "$(command -v clang++)" != "" ]]; then
      CXX=clang++
      CC=clang
    elif [[ "$(command -v g++)" != "" ]]; then
      CXX=g++
      CC=gcc
    else
      Die "Unable to determine C++ compiler"
    fi
  fi

  #-------------------------------------------------------------------------------
  # Scan command-line for options
  #-------------------------------------------------------------------------------
  declare -a ARGV # Holds left-overs
  export ARGV
  HELPSCRIPT='$p = $ARGV; $p =~ s{.*/}{}; if ( $_ =~ s{^#\|}{} ) { $_ =~ s{\$0}{$p}; print; }'
  while [[ $# != 0 ]]; do
    case "$1" in
    -devhelp)
      perl -ne "${HELPSCRIPT}" "$0";
      exit 0
      ;;
    -h|-help)
      perl -ne "${HELPSCRIPT}" "$1";
      exit 0
      ;;
    --cc=*|CC=*)
      export CC CXX
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
      export CLEAN
      shift;
      ;;
    --cxx=*|CXX=*)
      export CC CXX
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
      export DEBUG
      shift;
      ;;
    --default)
      APPS="${HOME}.local/apps"
      SRC="${HOME}/.local/src"
      export APPS SRC
      shift
      ;;
    --gcc)
      CC=gcc
      CXX=g++
      shift
      ;;
    -i|--install=*|--apps=)
      if [[ "$1" != '-i' ]]; then
        APPS="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        APPS="$2"
        shift
      else
        Die "Need directory argument for $1"
      fi
      export APPS
      shift
      ;;
    --home)
      APPS="${HOME}"
      SRC="${HOME}/src"
      export APPS SRC
      shift
      ;;
    -s|--src=*)
      if [[ "$1" != '-s' ]]; then
        SRC="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SRC="$2"
        shift
      else
        Die "Need directory argument for $1"
      fi
      export SRC
      shift
      ;;
    --std=*|-std=*)
      CMAKE_CXX_STANDARD="${1//*=}"
      shift;
      ;;
    --suffix=*|-suf)
      export SUFFIX
      if [[ "$1" != '-suf' ]]; then
        SUFFIX="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SUFFIX="$2"
        shift
      else
        Die "Need argument for $1"
      fi
      shift;
      ;;
    *)
      ARGV[${#ARGV[*]}]="$1"
      shift
      ;;
    esac
  done

  if [[ ${DEBUG} != 0 ]]; then
    Debug "SCRIPT='${SCRIPT}' DEBUG=${DEBUG}"
    Debug "APPS='${APPS}' SRC='${SRC}' SUFFIX='${SUFFIX}'"
    Debug "CC='${CC}' CXX='${CXX}'"
    Debug "CMAKE_CXX_STANDARD='${CMAKE_CXX_STANDARD}'"
    for(( i=0; i<${#ARGV[@]}; ++i)); do
      Debug "ARGV[${i}]='${ARGV[${i}]}'"
    done
  fi

  #-------------------------------------------------------------------------------
  # Setup apps directory
  if [[ "${APPS}" != '' && -d "${APPS}" ]]; then
    echo "Using APPS=${APPS}"
  else
    APPS="${HOME}/.local/apps"
    echo "Using APPS=${APPS}"
  fi
  mkdir -p "${APPS}" || Die "Failed to find/create ${APPS} directory"

  #-------------------------------------------------------------------------------
  Info "Setup source directory"
  if [[ "${SRC}" != '' && -d "${SRC}" ]]; then
    echo "Using SRC=${SRC}"
  else
    if [[ "${APPS}" == '/apps' ]]; then
      SRC="${APPS}/src"
    elif [[ "${APPS}" != '' ]]; then
      SRC="$(dirname "${APPS}")/src"
    elif [[ "${HOME}" == "$(pwd)" ]]; then
      SRC="${HOME}/.local/src"
    else
      SRC="$(pwd)/src"
    fi
  fi
  mkdir -p "${SRC}" || Die "Failed to find/create ${SRC} directory"

  cd "${SRC}" || Die "Unable to change into source directory"

}
