#!/usr/bin/env bash
#
# source this file to setup project

TITLE="{:DESCRIPTION:}"
export ACTION

function Report_info()  { echo "Info: $*" ; }
function Report_warning() { echo "Warning: $*" 1>&2; }
function Report_error() { echo "Error: $*" 1>&2 ; return 1; }
function Realpath() { /usr/bin/perl '-MCwd(abs_path)' -le '$p=abs_path(join(q( ),@ARGV));print $p if -e $p' "$*" ; }
function Has_path() {
  local arg plscript
  arg="$(Realpath "$2")"
  # shellcheck disable=SC2016
  plscript='$v=$ARGV[0]; $p=$ARGV[1]; for $d (split(qq{:},$ENV{$v})) { next if !-d $d; exit 0 if$p eq abs_path($d); } exit 1'
  if [[ -z "${arg}" ]]; then return 1; fi
  perl -M'Cwd(abs_path)' -le "${plscript}" "$1" "${arg}"
}
function Unique_path() {
  local PERL_SCRIPT EVAL_TEXT
  if [[ "${SHELL}" =~ zsh ]]; then set -o shwordsplit ; fi
  # shellcheck disable=SC2016
  PERL_SCRIPT='$v=shift @ARGV;exit 1 if not exists $ENV{$v};
    for $d(split(qr{:},$ENV{$v})){next if !-d $d;$e=abs_path($d);if(!exists $e{$e}){$e{$e}=1;push(@e,$e);}}
    printf qq{%s="%s"\n},$v,join(":",@e);'
  EVAL_TEXT="$(perl -M'Cwd(abs_path)' -e "${PERL_SCRIPT}" "$1")"
  eval "${EVAL_TEXT}"
}
function Prepend_path() { # only if 2nd arg does not exist in first
  if [[ $# != 2 ]]; then Report_error "Prepend_path requires two arguments"; return 1; fi
  local VAR ARG EVAL
  VAR="$1"
  ARG="$(Realpath "$2")"; shift
  EVAL="${VAR}=\"${ARG}:\$${VAR}\"; export ${VAR}"
  eval "${EVAL}"
  Unique_path "${VAR}"
}

# Directory where shared includes, libraries and applications are installed.
# Using home installation when /usr/local is not possible.
APPS="${HOME}/.local/apps"

# Point to the top-level of this repository
if git rev-parse --show-toplevel 2>/dev/null 1>/dev/null; then
  PROJECT_DIR="$(git rev-parse --show-toplevel)"
else
  Report_error "This script is intended to be run inside the exercises directory -- aborting"
  return 1
fi
export APPS PROJECT_DIR

Prepend_path MANPATH "${PROJECT_DIR}/externs/share/man"
Prepend_path PATH "${PROJECT_DIR}/externs/bin"
Prepend_path PATH "${PROJECT_DIR}/bin"

# Cmake should refer to project and group directories to find scripts
CMAKE_PREFIX_PATH="${PROJECT_DIR}/cmake;${APPS}/cmake;${PROJECT_DIR}/externs/lib/cmake"
export CMAKE_PREFIX_PATH

if [[ ! -d "${APPS}/cmake" ]]; then
  Report_warning "${APPS} missing!? Did you install portable scripts?"
fi
if [[ ! -d "${PROJECT_DIR}/externs/lib/cmake" ]]; then
  Report_warning "${PROJECT_DIR}/externs/lib/cmake missing!? Did you build GoogleTest?"
fi

if [[ "${ACTION}" != xdd ]]; then
  Report_info "${TITLE}"
fi

# vim:nospell
