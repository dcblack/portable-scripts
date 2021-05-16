#!/bin/bash

function project_init() {
  local TIMESTAMP="$(date +%y%m%d-%H%M%S)"
  local VERBOSE=0
  if [[ "$1" == "-v" ]]; then VERBOSE=1 fi
  if [[ $VERBOSE == 1 ]]; then echo "Host: $(hostname)"; fi
  for DOTFILE in bash_aliases vim vimrc; do
    if [[ -h "${HOME}/.${DOTFILE}" ]]; then
      if [[ $VERBOSE == 1 ]]; then echo "WARNING: Leaving .${DOTFILE} in place"; fi
      continue;
    elif [[ -d "${HOME}/.${DOTFILE}" ]]; then
      if [[ $VERBOSE == 1 ]]; then echo "WARNING: Leaving .${DOTFILE} in place"; fi
      continue;
    elif [[ -f "${HOME}/.${DOTFILE}" ]]; then
      bash -v -c "mv '${HOME}/.${DOTFILE}' '${HOME}/.${DOTFILE}-${TIMESTAMP}'";
    fi
    bash -v -c "ln -s '${HOME}/.local/dotfiles/${DOTFILE}' '${HOME}/.${DOTFILE}'";
  done
}

project_init
