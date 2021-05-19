#!/bin/bash

function project_init() {
  local TIMESTAMP VERBOSE
  TIMESTAMP="$(date +%y%m%d-%H%M%S)";
  VERBOSE=0;
  if [[ "$1" == "-v" ]]; then VERBOSE=1; fi
  if [[ ${VERBOSE} == 1 ]]; then echo "Host: $(hostname)"; fi
  
  # Add symbolic links to select "dot" files
  for DOTFILE in bash_aliases vim vimrc; do
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
  done
  
  # Make sure `ag` (aka silver-searcher) doesn't search .snapshots
  AGIGNORE="${HOME}/.agignore"
  for IGNORED in .snapshots; do
    if [[ -r "${AGIGNORE}" ]]; then
      grep -sqF "${IGNORED}" "${AGIGNORE}" \
      || echo "${IGNORED}" >> "${AGIGNORE}"
    else
      echo "${IGNORED}" > "${AGIGNORE}"
    fi
  done
}

project_init "$@"
