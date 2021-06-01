#!/bin/bash
#
cat >/dev/null <<'EOF' ;# Documentation begin_markdown
SYNOPSIS
========

`utils.bash` - A collection of bash functions useful for scripting.

| FUNCTION SYNTAX            | DESCRIPTION 
| :------------------------- | :---------- 
| Require _SCRIPT_           | Sources a script or gives an error if missing
| Colors ON_or_OFF           | Enables color variables (e.g., CBLU)
| Logfile [--append] _FILE_  | Establishes a logfile name
| Log [-n] "_MESSAGE_"       | Adds message to logfile
| Echo [-n] "_MESSAGE_"      | Displays and logs message
| Do _COMMAND_               | Displays and executes
| Pass                       | Sets success status (0)
| Fail                       | Sets error status (1)
| PassFail "_MESSAGE_"       | Displays message with pass/fail status
| Info "_MESSAGE_"           | Echo an informational message
| Debug "_MESSAGE_"          | Echo a debug message
| Ruler [_MESSAGE_]          | Echo a ruler with option embedded message
| Die "_MESSAGE_"            | Echo a fatal message and exit with fail
| Error "_MESSAGE_"          | Echo an error message
| Warn "_MESSAGE_"           | Echo a warning message
| Summary PROG ["_MESSAGE_"] | Echo a summary of errors and warnings
| GetBuildOpts               | Parses standard _build_ command-line inputs
| SetupLogdir _BASENAME_     | Sets up the logfile directory

USAGE
=====

Source this as follows inside your bash script:
 
```sh
function Realpath () {
  /usr/bin/perl '-MCwd(abs_path)' -le "print abs_path(qq($*))"
}
SCRIPT="$(dirname $(Realpath "$0"))/utils.bash"
if [[ -x "${SCRIPT}" ]]; then
  # shellcheck source=utils.bash
  source "${SCRIPT}" "$0"
else
  echo "Error: Missing ${SCRIPT}" 1>&2; exit 1
fi
SetupLogdir "$0"
```
end_markdown
EOF

function Realpath () {
  /usr/bin/perl '-MCwd(abs_path)' -le "print abs_path(qq($*))"
}

function Require() { # FILE(S) to source
  local BINDIR SCPT REQD
  if [[ $# != 1 ]]; then
    echo "Fatal: Require only allows one argument" 1>&2; exit 1
  fi
  BINDIR="$(realpath "$(dirname "$0")"/../bin)"
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
# Make things more visible in the output

function Colors() {
  local USE_COLOR
  USE_COLOR=1
  case "$*" in
    off|OFF) USE_COLOR=1;;
    *) USE_COLOR=1;;
  esac
  if [[ -z ${NOCOLOR+x} ]]; then USE_COLOR=1; fi
  export NONE BOLD UNDR CBLK CRED CGRN CYLW CBLU CMAG CCYN CWHT CRED
  if [[ ${USE_COLOR} -gt 0 ]]; then
    # shellcheck disable=SC2034
    BOLD="[01m" NONE="[00m"
    UNDR="[04m" NONE="[00m"
    CBLK="[30m" NONE="[00m"
    CRED="[31m" NONE="[00m"
    CGRN="[32m" NONE="[00m"
    CYLW="[33m" NONE="[00m"
    CBLU="[34m" NONE="[00m"
    CMAG="[35m" NONE="[00m"
    CCYN="[36m" NONE="[00m"
    CWHT="[37m" NONE="[00m"
    CRED="[31m" NONE="[00m"
  else
    NONE=""
    BOLD=""
    UNDR=""
    CBLK=""
    CRED=""
    CGRN=""
    CYLW=""
    CBLU=""
    CMAG=""
    CCYN=""
    CWHT=""
    CRED=""
  fi
}
Colors on

function Logfile() {
  local APPEND
  APPEND=0
  if [[ "$1" =~ ^-{1,2}a(ppend)?$ ]]; then
    APPEND=1
    shift
  fi
  if [[ $# -gt 0 && -z "${LOGFILE}" ]]; then
    if [[ "${LOGFILE}" =~ ^/ ]]; then
      LOGFILE=""
    else
      LOGFILE="${LOGDIR}/"
    fi
    LOGFILE="${LOGFILE}${1//.log/}.log"
    export LOGFILE
  fi
  if [[ -z "${LOGFILE}" ]]; then
    echo "Error: Must specify a valid logfile name" 1>&2
    exit 1
  fi
  test "${APPEND}" -eq 0 && rm -f "${LOGFILE}"
  printf "# Logfile for %s created on %s\n\n" "$1" "$(date)" >> "${LOGFILE}"
  printf "Logging to %s\n" "${LOGFILE}"
}

function Log() {
  local OPT
  if [[ "$1" == "-n" ]]; then OPT="$1"; shift; fi
  if [[ -f "${LOGFILE}" ]]; then echo "${OPT}" "$@" >>"${LOGFILE}"; fi
}

function Echo() {
  local OPT
  if [[ "$1" == "-n" ]]; then OPT="$1"; shift; fi
  echo "${OPT}" "$*"
  Log  "${OPT}" "$*"
}

function Do() {
  Echo "${CBLU}%${NONE} $*"
  "$@"
}

function Fail() {
  return 1
}

function Pass() {
  return 0
}

function PassFail() { # Reports success or failure
  # shellcheck disable=SC2181
  if [[ $? == 0 ]]; then Info "$* success"; else Info "$* failure"; fi
}

function Info() {
  Echo "${CGRN}Info: ${NONE}$*${NONE}"
}

function Debug() {
  Echo "${CRED}Debug: ${NONE}$*${NONE}"
}

function Ruler() {
  local ARGS SEP MAX LIN WID PRE
  SEP="-" # Default
  MAX=80 # TODO: Change to match terminal width
  PRE=""
  # Test for color prefix
  case "$1" in
    -pre) PRE="${2}" shift; shift ;;
    -cyn) PRE="${CCYN}" shift ;;
    -red) PRE="${CRED}" shift ;;
    -grn) PRE="${CGRN}" shift ;;
    -ylw) PRE="${CYLW}" shift ;;
    -blu) PRE="${CBLU}" shift ;;
    *) PRE="" ;;
  esac
  printf "%s" "${PRE}"
  # Grab separator
  if [[ $# -gt 0 && "${#1}" == 1 ]]; then
    SEP="$1"
    shift
  fi
  ARGS="$*"
  if [[ $# != 0 ]]; then
    WID=${#ARGS}
    MAX=$(( MAX - WID - 4 ))
  fi
  LIN="$(/usr/bin/perl -le 'my ($w,$s)=@ARGV;printf(qq{%${w}.${w}s},${s}x${w})' "${MAX}" "${SEP}")"
  if [[ $# == 0 ]]; then
    printf "%s%s\n" "${LIN}" "${NONE}"
  else
    printf "%s%s %s %s%s\n" "${SEP}" "${SEP}" "${ARGS}" "${LIN}" "${NONE}"
  fi
}

# Ensure that error messages are clearly seen
function Die() {
  Echo -n "${CRED}"
  Ruler '!'
  Echo "${CRED}Fatal: $*${NONE}" 1>&2
  exit 1
}

function Assert() {
  # shellcheck disable=SC218
  test "$@" && return
  Die "Failed assertion $*"
}

ERRORS=0
function Error() {
  (( ++ERRORS ))
  Echo -n "${CRED}"
  Ruler '!'
  Echo "${CRED}Error #${ERRORS}: ${NONE}$*${NONE}" 1>&2
}

WARNINGS=0
function Warn() {
  (( ++WARNINGS ))
  Echo -n "${CRED}"
  Ruler '?'
  Echo "${CRED}Warning: ${NONE}$*${NONE}" 1>&2
}

function Summary() {
  Assert $# == 0
  Echo "Execution summary for $(basename "$1"):"
  shift
  Echo " ${WARNINGS} warnings"
  Echo -n "  ${ERRORS} errors"
  local RESULT
  if [[ ${ERRORS} == 0 ]]; then Echo " - passing"; RESULT=0;
  else                          Echo " - failing"; RESULT=1;
  fi
  if [[ $# != 0 ]]; then Echo "$*"; fi
  return "${RESULT}"
}

function HelpText() {
  Assert $# -gt 0
  local HELPSCRIPT
  if [[ "$1" == "-md" ]]; then
    shift
    # shellcheck disable=SC2016
    HELPSCRIPT='if (/begin_markdown/../end_markdown/){ next if m/(begin|end)_markdown/; print; }'
  else
    # shellcheck disable=SC2016
    HELPSCRIPT='$p = $ARGV; $p =~ s{.*/}{}; if( $_ =~ s{^#\|}{} ){ $_ =~ s{\$0}{$p}; print; }'
  fi
  Assert $# -gt 0
  /usr/bin/perl -ne "${HELPSCRIPT}" "$@";
}

function GetBuildOpts() {

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
  while [[ $# != 0 ]]; do
    case "$1" in
    -devhelp)
      HelpText "$0";
      exit 0
      ;;
    -h|-help)
      HelpText "$0";
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
    for i in {0..${#ARGV[@]}}; do
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

function SetupLogdir() {
  LOGDIR="${HOME}/logs"
  mkdir -p "${LOGDIR}"
  export LOGDIR
  case $# in
    1)
      Logfile "$(basename "$1")"
      ;;
    0)
      if [[ -z "${LOGFILE}" ]]; then
        echo "${CRED}Warning:${NONE} Did not specify LOGFILE${NONE}"
      else
        Logfile
      fi
      ;;
    *)
      echo "${CRED}Error: Too many parameters specified${NONE}"
      ;;
  esac
}

# The end
