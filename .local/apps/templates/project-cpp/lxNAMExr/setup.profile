#!/usr/bin/env bash
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if [[ ${SOURCED} == 0 ]]; then
  echo "Don't run $0, source it" >&2
  exit 1
fi

# source this file to setup project

TITLE="{:DESCRIPTION:}"
export ACTION

#-------------------------------------------------------------------------------
# Useful functions
function Report_info()  { echo "Info: $*" ; }
function Report_warning() { echo "Warning: $*" 1>&2; }
function Report_error() { echo "Error: $*" 1>&2 ; return 1; }
function Realpath() { # Determines the full Linuix pathname of a file or directory
  /usr/bin/perl '-MCwd(abs_path)' -le '$p=abs_path(join(q( ),@ARGV));print $p if -e $p' "$*" ;
}
function Has_path() { # Determines if environment variable contains a particular path
  # Has_path VARIABLE_NAME PATH_TO_FIND
  local arg plscript
  arg="$(Realpath "$2")"
  # shellcheck disable=SC2016
  plscript='$v=$ARGV[0]; $p=$ARGV[1]; for $d (split(qq{:},$ENV{$v})) { next if !-d $d; exit 0 if$p eq abs_path($d); } exit 1'
  if [[ -z "${arg}" ]]; then return 1; fi
  perl -M'Cwd(abs_path)' -le "${plscript}" "$1" "${arg}"
}
function Unique_path() { # Removes duplicates from environment variables (e.g., PATH)
  # Unique_path VARIABLE_NAME
  local PERL_SCRIPT EVAL_TEXT
  if [[ -n "${ZSH_VERSION}" ]]; then set -o shwordsplit ; fi
  # shellcheck disable=SC2016
  PERL_SCRIPT='$v=shift @ARGV;exit 1 if not exists $ENV{$v};
    for $d(split(qr{:},$ENV{$v})){next if !-d $d;$e=abs_path($d);if(!exists $e{$e}){$e{$e}=1;push(@e,$e);}}
    printf qq{%s="%s"\n},$v,join(":",@e);'
  EVAL_TEXT="$(perl -M'Cwd(abs_path)' -e "${PERL_SCRIPT}" "$1")"
  eval "${EVAL_TEXT}"
}
function Remove_path() { # Removes specified path from environment variables (e.g., PATH)
  # Remove_path VARIABLE_NAME PATH_TO_REMOVE
  export Remove_path_VERSION=1.4
  # USAGE: remove_path VAR PATH
  if [[ $# != 2 ]]; then Report_error "Remove_path requires two arguments"; return 1; fi
  if [[ "$1" =~ ^[_A-Za-z][-_A-Za-z0-9]*$ ]]; then
    local PLSCRIPT EVALSCRIPT VAR VAL REMOVE
    VAR="$1"
    REMOVE="$2"
    eval "VAL=\$${VAR}"
    # shellcheck disable=SC2016
    PLSCRIPT='$v=$ARGV[0];$p=abs_path($ARGV[1]);@o=split(/:/,$ENV{$v});for(@o){$e=abs_path($_);push(@e,$e) if $p ne $e;} printf qq{$v="%s"\n},join(":",@e);'
    EVALSCRIPT="$(env "${VAR}=${VAL}" perl -M'Cwd(abs_path)' -e "${PLSCRIPT}" "${VAR}" "${REMOVE}")"
    eval "${EVALSCRIPT}"
  else
    Report_error "Remove_path requires first argument be a simple variable name"
    return 1
  fi
}
function Prepend_path() { # only if 2nd arg does not exist in first
  # Prepend_path VARIABLE_NAME PATH_TO_INSERT
  if [[ $# != 2 ]]; then Report_error "Prepend_path requires two arguments"; return 1; fi
  local VAR ARG EVAL
  VAR="$1"
  ARG="$(Realpath "$2")"; shift
  EVAL="${VAR}=\"${ARG}:\$${VAR}\"; export ${VAR}"
  eval "${EVAL}"
  Unique_path "${VAR}"
}

#-------------------------------------------------------------------------------
# Directory where shared includes, libraries and applications are installed.
# Using home installation when /usr/local is not possible.
APPS="${HOME}/.local/apps"

#-------------------------------------------------------------------------------
# Point to the top-level of this repository
if git rev-parse --show-toplevel 2>/dev/null 1>/dev/null; then
  WORKTREE_DIR="$(git rev-parse --show-toplevel)"
else
  Report_error "This script is intended to be run inside the exercises directory -- aborting"
  return 1
fi
export APPS WORKTREE_DIR

if [[ "${ACTION}" != rm ]]; then
  Prepend_path MANPATH "${WORKTREE_DIR}/extern/share/man"
  Prepend_path PATH "${WORKTREE_DIR}/extern/bin"
  Prepend_path PATH "${WORKTREE_DIR}/bin"
else
  Remove_path  MANPATH "${WORKTREE_DIR}/extern/share/man"
  Remove_path  PATH "${WORKTREE_DIR}/extern/bin"
  Remove_path  PATH "${WORKTREE_DIR}/bin"
fi

#-------------------------------------------------------------------------------
# Cmake should refer to project and group directories to find scripts
CMAKE_PREFIX_PATH="${WORKTREE_DIR}/cmake;${APPS}/cmake;${WORKTREE_DIR}/extern/lib/cmake"
export CMAKE_PREFIX_PATH

#-------------------------------------------------------------------------------
# Check installation
if [[ ! -d "${APPS}/cmake" ]]; then
  Report_warning "${APPS} missing!? Did you install portable scripts?"
fi
if [[ ! -d "${WORKTREE_DIR}/extern/lib/cmake" ]]; then
  Report_warning "${WORKTREE_DIR}/extern/lib/cmake missing!? Did you build GoogleTest?"
fi

#-------------------------------------------------------------------------------
# Display current project "title"
if [[ "${ACTION}" == add ]]; then
  Report_info "${TITLE}"
fi

# vim:nospell
