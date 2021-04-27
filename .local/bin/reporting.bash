#!/bin/bash
#
# Source this as follows in every bash script:
#
# SCRIPT="$(dirname "$0")/reporting.bash"
# if [[ -x "${SCRIPT}" ]]; then
#   shellcheck source=reporting.bash
#   source "${SCRIPT}" "$0"
# else
#   echo "Error: Missing ${SCRIPT}" 1>&2; exit 1
# fi

function Require() { # FILE(S) to source
  local BINDIR SCPT REQD
  if [[ $# != 1 ]]; then
    echo "Fatal: Require only allows one argument" 1>&2; exit 1
  fi
  BINDIR="$(dirname "$0")"
  SCPT="$1"; shift
  REQD="${BINDIR}/${SCPT}"
  if [[ -f "${REQD}" ]]; then
    # shellcheck disable=SC1093
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
  LIN="$(perl -le 'my ($w,$s)=@ARGV;printf(qq{%${w}.${w}s},${s}x${w})' "${MAX}" "${SEP}")"
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
  Echo "Execution summary for $(basename "$0"):"
  Echo " ${WARNINGS} warnings"
  Echo -n "  ${ERRORS} errors"
  local RESULT
  if [[ ${ERRORS} == 0 ]]; then
    Echo " - passing"; RESULT=0;
  else
    Echo " - failing"; RESULT=1; fi
  return "${RESULT}"
  if [[ $# != 0 ]]; then Echo "$*"; fi
}

case $# in
  1)
    LOGFILE="$(pwd)/$(basename "$1").log"
    rm -f "${LOGFILE}"
    printf "# Logfile for %s created on %s\n\n" "$1" "$(date)" >> "${LOGFILE}"
    printf "Logging to %s\n" "${LOGFILE}"
    ;;
  0)
    if [[ -z "${LOGFILE}" ]]; then
      echo "${CRED}Warning:${NONE} Did not specify LOGFILE${NONE}"
    else
      printf "\n# Logfile for %s on %s\n\n" "$1" "$(date)" >> "${LOGFILE}"
      printf "Logging to %s\n" "${LOGFILE}"
    fi
    ;;
  *)
    echo "${CRED}Error: Too many parameters specified${NONE}"
    ;;
esac
