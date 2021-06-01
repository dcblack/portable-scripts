#!/bin/bash
#
#-------------------------------------------------------------------------------
# The following is formatted for use with -help
#|
#|NAME
#|----
#|
#| project_init.sh - executed on startup by CoCalc in $HOME directory.
#|
#|SYNOPSIS
#|--------
#|
#|  $0 -help
#|  $0 [OPTIONS...]
#|
#|DESCRIPTION
#|-----------
#|
#| Set-up symbolic links for the portable scripts tools.
#|
#|OPTIONS
#|-------
#|
#| -v verbose output
#|

# Wrap body in function to allow local variables
function Project_init() {
  local TIMESTAMP VERBOSE
  TIMESTAMP="$(date +%y%m%d-%H%M%S)";
  VERBOSE=0;
  if [[ "$1" == "-v" ]]; then VERBOSE=1; fi
  if [[ ${VERBOSE} == 1 ]]; then echo "Host: $(hostname)"; fi
  
  # Add symbolic links to select "dot" files
  for DOTFILE in bash_aliases vim vimrc lessfilter; do
    if [[ -r "${HOME}/.local/dotfiles/${DOTFILE}" ]]; then
      if [[ -h "${HOME}/.${DOTFILE}" ]]; then
        if [[ ${VERBOSE} == 1 ]]; then echo "WARNING: Leaving .${DOTFILE} in place"; fi
        continue;
      elif [[ -d "${HOME}/.${DOTFILE}" ]]; then
        if [[ ${VERBOSE} == 1 ]]; then echo "WARNING: Leaving .${DOTFILE} in place"; fi
        continue;
      elif [[ -f "${HOME}/.${DOTFILE}" ]]; then
        bash -v -c "mv '${HOME}/.${DOTFILE}' '${HOME}/.${DOTFILE}-${TIMESTAMP}'";
      fi
      bash -v -c "ln -s '${HOME}/.local/dotfiles/${DOTFILE}' '${HOME}/.${DOTFILE}'";
    else
      echo "Missing ${HOME}/.local/dotfiles/${DOTFILE}" 1>&2
    fi
  done
  
  # Make sure `ag` (aka silver-searcher) doesn't search .snapshots
  AGIGNORE="${HOME}/.agignore"
  for IGNORED in .snapshots .hide; do
    if [[ -r "${AGIGNORE}" ]]; then
      grep -sqF "${IGNORED}" "${AGIGNORE}" \
      || echo "${IGNORED}" >> "${AGIGNORE}"
    else
      echo "${IGNORED}" > "${AGIGNORE}"
    fi
  done
}

Project_init "$@"
