#!/usr/bin/env bash
#
cat >/dev/null <<'EOF' ;# Documentation begin_markdown
SYNOPSIS
========

`utils.bash` - A collection of bash functions useful for scripting.

Note: Capitalizing function names reduces collisions with scripts/executables.

| FUNCTION SYNTAX            | DESCRIPTION 
| :------------------------- | :---------- 
| Require _SCRIPT_           | Sources a script or gives an error if missing
| Colors ON_or_OFF           | Enables color variables (e.g., CBLU)
| Logfile [--append] _FILE_  | Establishes a logfile name
| Log [-n] "_MESSAGE_"       | Adds message to logfile
| Echo [-n] "_MESSAGE_"      | Displays and logs message
| _do _COMMAND_              | Displays and executes
| Pass                       | Sets success status (0)
| Fail                       | Sets error status (1)
| PassFail "_MESSAGE_"       | Displays message with pass/fail status
| Info "_MESSAGE_"           | Echo an informational message
| Comment "_MESSAGE_"        | Does nothing but provide NOP comment
| Debug "_MESSAGE_"          | Echo a debug message
| Ruler [-CLR] [_MESSAGE_]   | Echo a ruler with option embedded message
| Die "_MESSAGE_"            | Echo a fatal message and exit with fail
| Error "_MESSAGE_"          | Echo an error message
| Warn "_MESSAGE_"           | Echo a warning message
| Summary PROG ["_MESSAGE_"] | Echo a summary of errors and warnings
| GetBuildOpts "$0" "$@"     | Parses standard _build_ command-line inputs
| ShowBuildOpts              | Display options variables from GetBuildOpts
| ConfirmBuildOpts || exit   | Asks user to confirm build locations
| SetupLogdir _BASENAME_     | Sets up the logfile directory
| GetSource_and_Cd DIR URL   | Downloads souce and enters directory
| Generate TYPE              | Invokes cmake or autotools
| Cleanup_Source             | Removes source

USAGE
=====

Source this as follows inside your bash script:
 
```sh
function Realpath () {
  /usr/bin/perl '-MCwd(abs_path)' -le "print abs_path(qq($*))"
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
end_markdown
EOF

declare -a ARGV
export APPS
export ARGV
export CC
export CLEAN
export CLEANUP
export CMAKE_CXX_STANDARD
export CMAKE_INSTALL_PREFIX
export CXX
export DEBUG
export ERRORS
export GENERATOR
export LOGDIR
export LOGFILE
export NOTREALLY
export SRC
export SYSTEMC_HOME
export SUFFIX
export TOOL_NAME
export TOOL_INFO
export TOOL_VERS
export TOOL_URL
export BUILD_DIR
export GENERATOR
export NOINSTALL
export UNINSTALL
export VERBOSITY
export WARNINGS
export NONE BOLD UNDR CBLK CRED CGRN CYLW CBLU CMAG CCYN CWHT CRED

function Comment() {
  true;
}

# Following is 'just in case you did not define this'
function Realpath () {
#@ Output the realpath name treating all arguments as a single filename specification
  /usr/bin/perl '-MCwd(abs_path)' -le "print abs_path(qq($*))"
}

function Firstreal() {
#@ Output the first argument that names an existing file.
  perl -le '@_=split($;,join($;,@ARGV));for(@_){next unless -e $_;print $_;exit 0;}' "$@"
}

function Has_path() {
  # USAGE: Has_path VAR PATH
  local arg plscript
  arg="$(Realpath "$2")"
  # shellcheck disable=SC2016
  plscript='$v=$ARGV[0]; $p=$ARGV[1]; for $d (split(qq{:},$ENV{$v})) { next if !-d $d; exit 0 if$p eq abs_path($d); } exit 1'
  if [[ "${arg}" == "" ]]; then return 1; fi
  perl -M'Cwd(abs_path)' -le "${plscript}" "$1" "${arg}"
}

function Prepend_path() { # only if 2nd arg does not exist in first
  # USAGE: Prepend_path VAR PATH
  local arg plscript
  arg="$(Realpath "$2")"
  # shellcheck disable=SC2016
  plscript='print qq{$ARGV[0]="$ARGV[1]:$ENV{$ARGV[0]}"; export $ARGV[0]}'
  Has_path "$1" "$2" || \
    eval "$(perl -le "${plscript}" "$1" "${arg}")"
}

function Append_path() { # only if 2nd arg does not exist in first
  # USAGE: Append_path VAR PATH
  local var arg plscript
  var="$1"
  arg="$(Realpath "$2")"; shift
  # shellcheck disable=SC2016
  plscript='print qq{$ARGV[0]="$ENV{$ARGV[0]}:$ARGV[1]"; export $ARGV[0]}'
  Has_path "$1" "$2" || \
    eval "$(perl -le "${plscript}" "${var}" "${arg}")"
}

function Unique_path() {
  # USAGE: unique_path VAR
  local plscript
  # shellcheck disable=SC2016
  plscript='$v=$ARGV[0]; for my $d(split(qr{:},$ENV{$v})){ next if !-d $d; $e=abs_path($d); if( ! exists $e{$e} ){ $e{$e}=1; push(@e,$e); } } printf qq{%s="%s"\n},$v,join(":",@e);'
  eval "$(perl -M'Cwd(abs_path)' -e "${plscript}" "$1")"
}

function Remove_path() {
  # USAGE: remove_path VAR PATH
  local plscript
  # shellcheck disable=SC2016
  plscript=' $v=$ARGV[0]; $p=abs_path($ARGV[1]); for (split(qr":",$ENV{$v})) { $e=abs_path($_); if($p ne $e) { $push(@e,$e); } } print "$v=",join(":",@e) '
  eval "$(perl -M'Cwd(abs_path)' -e "${plscript}" "$1" "$2")"
}

function Add_prefix() {
  local prefix="$1"
  shift
  for element in "$@"; do
    echo "${prefix}${element}"
  done
}

function Add_suffix() {
  local suffix="$1"
  shift
  for element in "$@"; do
    echo "${element}${suffix}"
  done
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
# Verify existance of tools in search path

function Needs() {
  local I J X D P
  I=0 J=0
  for X in "$@"; do
    (( ++I ));
    for D in $(perl -le 'print join(q{\n},split(/:/,$ENV{PATH}))'); do
      Debug "Testing  ${D}/${X}"
      P="$(Realpath "${D}/${X}")"
      if [[ -n "${P}" && -x "${P}" && ! -d "${P}" ]]; then
        (( ++J ));
        echo "${P}"
        break
      else
        P=""
      fi
    done
    if [[ -z "${P}" ]]; then Error "Missing ${X}"; fi
  done
  if [[ "${I}" == "${J}" ]]; then
    return 0
  else
    return 1
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
  if [[ ${USE_COLOR} -gt 0 ]]; then
    # shellcheck disable=SC2034
    ESC=""
    BOLD="${ESC}[01m" NONE="${ESC}[00m"
    UNDR="${ESC}[04m" NONE="${ESC}[00m"
    CBLK="${ESC}[30m" NONE="${ESC}[00m"
    CRED="${ESC}[31m" NONE="${ESC}[00m"
    CGRN="${ESC}[32m" NONE="${ESC}[00m"
    CYLW="${ESC}[33m" NONE="${ESC}[00m"
    CBLU="${ESC}[34m" NONE="${ESC}[00m"
    CMAG="${ESC}[35m" NONE="${ESC}[00m"
    CCYN="${ESC}[36m" NONE="${ESC}[00m"
    CWHT="${ESC}[37m" NONE="${ESC}[00m"
    CRED="${ESC}[31m" NONE="${ESC}[00m"
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

function Printf() {
  # shellcheck disable=SC2059
  printf "$@"
  # shellcheck disable=SC2059
  if [[ -f "${LOGFILE}" ]]; then printf "$@" >>"${LOGFILE}"; fi
}

function _do() {
  local NX
  if [[ -n "${NOTREALLY}" ]]; then NX="-"; fi
  if [[ "$1" == "-n" ]]; then NX="-"; shift; fi
  Echo "${CBLU}${NX}%${NONE} ${BOLD}$*${NONE}"
  if [[ "${NX}" == "-" ]]; then return; fi
  "$@"
}

function Fail() {
  return 1
}

function Pass() {
  return 0
}

function Info() {
  if [[ -s "${VERBOSITY}" || "${VERBOSITY}" -lt 0 ]]; then
    return 0
  fi
  local PRE
  # Test for color prefix
  case "$1" in
    -pre) PRE="${2}"    ; shift  ; shift ;;
    -cyn) PRE="${CCYN}" ; shift ;;
    -red) PRE="${CRED}" ; shift ;;
    -grn) PRE="${CGRN}" ; shift ;;
    -ylw) PRE="${CYLW}" ; shift ;;
    -blu) PRE="${CBLU}" ; shift ;;
    -mag) PRE="${CMAG}" ; shift ;;
    -wht) PRE="${CWHT}" ; shift ;;
    *) PRE="${NONE}" ;;
  esac
  Echo "${CGRN}Info: ${PRE}$*${NONE}"
}

function PassFail() { # Reports success or failure
  # shellcheck disable=SC2181
  if [[ $# == 0 ]]; then
    if [[ $? == 0 ]]; then Info "${BOLD}${CGRN}success${NONE}"; else Info "${BOLD}${CRED}failure${NONE}"; fi
  else
    if [[ $? == 0 ]]; then Info "$* ${BOLD}${CGRN}success${NONE}"; else Info "$* ${BOLD}${CRED}failure${NONE}"; fi
  fi
}

function Debug() {
  if [[ -n "${DEBUG}" && "${DEBUG}" != 0 ]]; then
    Echo "${CRED}Debug: ${NONE}$*${NONE}"
  fi
}

function Ruler() {
  local ARGS SEP MAX LIN WID
  SEP="-" # Default
  MAX=80 # TODO: Change to match terminal width
  local PRE
  PRE=""
  # Test for color prefix
  case "$1" in
    -pre) PRE="${2}"    ; shift  ; shift ;;
    -cyn) PRE="${CCYN}" ; shift ;;
    -red) PRE="${CRED}" ; shift ;;
    -grn) PRE="${CGRN}" ; shift ;;
    -ylw) PRE="${CYLW}" ; shift ;;
    -blu) PRE="${CBLU}" ; shift ;;
    *) PRE="" ;;
  esac
  Printf "%s" "${PRE}"
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
    Printf "%s%s\n" "${LIN}" "${NONE}"
  else
    Printf "%s%s %s %s%s\n" "${SEP}" "${SEP}" "${ARGS}" "${LIN}" "${NONE}"
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
  local FNC FIL LNO
  FNC="${FUNCNAME[1]}"
  FIL="${BASH_SOURCE[1]}"
  LNO="${BASH_LINENO[0]}"
  Die "Failed assertion '$*' from ${FNC} in ${FIL}:${LNO}"
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
  Assert $# != 0
  Echo "Execution summary for ${1}:"
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

function ShowVar() {
  local DLR VAR VAL
  VAR="$1"
  DLR='$'
  VAL="$(eval "echo ${DLR}${VAR}")"
  if [[ -n "${VAL}" ]]; then
    echo "${1}=${VAL}"
  fi
}

function ShowBuildOpts() {
  Ruler -blu "Build Options"
  for (( i=0; i<${#ARGV[@]}; ++i )); do
    Debug "ARGV[${i}]='${ARGV[${i}]}'"
  done
  ShowVar APPS
  ShowVar CLEAN
  ShowVar CLEANUP
  ShowVar CMAKE_CXX_STANDARD
  ShowVar CMAKE_INSTALL_PREFIX
  ShowVar CC
  ShowVar CXX
  ShowVar DEBUG
  ShowVar LOGDIR
  ShowVar LOGFILE
  ShowVar NOTREALLY
  ShowVar SRC
  ShowVar SYSTEMC_HOME
  ShowVar SUFFIX
  ShowVar TOOL_NAME
  ShowVar TOOL_INFO
  ShowVar TOOL_VERS
  ShowVar TOOL_URL
  ShowVar BUILD_DIR
  ShowVar GENERATOR
  ShowVar NOINSTALL
  ShowVar UNINSTALL
  ShowVar VERBOSITY
  Ruler -blu
}

function ConfirmBuildOpts() {
  ShowBuildOpts
  while true; do
    printf "Confirm above options (Y/n)? "
    read -r REPLY
    case "${REPLY}" in
      y) return 0 ;;
      n) return 1 ;;
      *) REPLY=""; echo "Must reply with 'y' or 'n'" ;;
    esac
  done
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
#|  --notreally        |  -n               | don't execute, just show possibilities
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
#| - $LOGDIR
#| - $LOGFILE
#| - $NOTREALLY
#| - $NOINSTALL
#| - $SRC directory
#| - $SYSTEMC_HOME
#| - $SUFFIX
#| - $TOOL_NAME
#| - $TOOL_INFO
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

  # Grab program name
  local SCRIPT
  # shellcheck disable=SC2034
  SCRIPT="$1"
  shift

  # Defaults
  #-------------------------------------------------------------------------------
  CMAKE_CXX_STANDARD=17 # <---------- VERSION OF C++ YOUR COMPILER SUPPORTS
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
    --build-dir=*|-bd)
      if [[ "$1" != '-bd' ]]; then
        BUILD_DIR="${1//*=}"
      elif [[ $# -gt 1 && -d "$2" ]]; then
        BUILD_DIR="$2"
        shift
      else
        Die "Need argument for $1"
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
        Die "Need argument for $1"
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
        Die "Need argument for $1"
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
        Die "Need directory argument for $1"
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
        Die "Need argument for $1"
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
        Die "Need directory argument for $1"
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
        Die "Need argument for $1"
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
        Die "Need argument for $1"
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
        Die "Need argument for $1"
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
        Die "Need argument for $1"
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

  #-------------------------------------------------------------------------------
  # Test some assumptions
  if [[ "${GENERATOR}" =~ cmake|autotools ]]; then
    Comment all is ok
  else
    Error "GENERATOR must be one of 'cmake' or 'autotools'"
  fi

  #-------------------------------------------------------------------------------
  # Setup apps directory
  mkdir -p "${APPS}" || Die "Failed to find/create ${APPS} directory"

  #-------------------------------------------------------------------------------
  Info "Setup source directory"
  if [[ -z "${SRC}" || ! -d "${SRC}" ]]; then
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

  if [[ -n "${DEBUG}" && "${DEBUG}" != 0 ]]; then
    ShowBuildOpts
  fi

}

function SetupLogdir() {
  LOGDIR="${HOME}/logs"
  mkdir -p "${LOGDIR}"
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

function Create_and_Cd() {
  Assert $# = 1
  _do mkdir -p "${1}" || Die "Unable to create ${1}"
  _do cd "${1}" || Die "Unable to enter ${1} directory"
}

function GetSource_and_Cd() {
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
    _do git clone "${2}" "${1}" || Die "Unable to clone into ${1}"
  fi
  cd "${1}" || Die "Unable to enter ${1}"
  if [[ -s "${TOOL_VERS}" ]]; then
    _do git  checkout "${TOOL_VERS}"
  fi
}

function Generate() {
  Assert $# = 0
  case "${GENERATOR}" in
    cmake)
      _do rm -fr "${BUILD_DIR}"
      _do mkdir -p "${BUILD_DIR}" || Die "Unable to create build directory"
      _do cd "${BUILD_DIR}" || Die "Unable to enter ${BUILD_DIR} directory"
      _do cmake\
          -DCMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}"\
          -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD}"\
          ..
      ;;
    autotools)
      reconfigure
      _do mkdir -p "${BUILD_DIR}"
      _do cd "${BUILD_DIR}" || Die "Unable to enter ${BUILD_DIR}"
      _do env CXXFLAGS="-std=c++${CMAKE_CXX_STANDARD} -I/opt/local/include -I${SYSTEMC_HOME}/include"\
          ../configure --prefix="${SYSTEMC_HOME}"
      ;;
    *)
      Error "Unknown generator ${1}"
      ;;
  esac
}

function Cleanup() {
  Assert $# = 1
  if [[ -n "${CLEANUP}" && "${CLEANUP}" == 1 ]]; then
    cd "${SRC}" || Die "Unable to enter source directory"
    rm -fr "${1}"
  fi
}

function Main() {
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
