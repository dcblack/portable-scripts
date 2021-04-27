#!/bin/bash
#
# Establishes options for building

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
  if [[ "${GIT_URL}" == '' ]]; then
    GIT_URL="https://github.com/accellera-official/systemc.git"
  fi

  #-------------------------------------------------------------------------------
  # Scan command-line for options
  #-------------------------------------------------------------------------------
  declare -a ARGV # Holds left-overs
  export ARGV
  while [[ $# != 0 ]]; do
    case "$1" in
    -h|-help)
      perl -ne '$p = $ARGV; $p =~ s{.*/}{}; if ( $_ =~ s{^#\|}{} ) { $_ =~ s{\$0}{$p}; print; }' "$0";
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
    -i|--install=*|--apps=)
      if [[ "$1" != '-i' ]]; then
        APPS="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        APPS="$2"
        shift
      else
        Die "Need directory argument for --install"
      fi
      shift;
      export APPS
      ;;
    -s|--src=*)
      if [[ "$1" != '-s' ]]; then
        SRC="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SRC="$2"
        shift
      else
        Die "Need directory argument for --src"
      fi
      export SRC
      shift;
      ;;
    --std=*|-std=*)
      CMAKE_CXX_STANDARD="${1//*=}"
      shift;
      ;;
    --suffix=*|-suf)
      export SUFFIX
      if [[ "$1" != '-pf' ]]; then
        SUFFIX="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        SUFFIX="$2"
        shift
      else
        Die "Need directory argument for --src"
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
  fi
  if [[ "${APPS}" != '' ]]; then
    SRC="${APPS}/src"
  elif [[ "${HOME}" == "$(pwd)" ]]; then
    SRC="${HOME}/.local/src"
  else
    SRC="$(pwd)/src"
  fi
  mkdir -p "${SRC}" || Die "Failed to find/create ${SRC} directory"

  cd "${SRC}" || Die "Unable to change into source directory"

}
