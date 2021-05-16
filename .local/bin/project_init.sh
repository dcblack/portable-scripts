#!/bin/bash

TIMESTAMP="$(date +%y%m%d-%H%M%S)"
hostname
for DOTFILE in bash_aliases vim vimrc; do
  if [[ -h "${HOME}/.${DOTFILE}" ]]; then
    echo "WARNING: Leaving .${DOTFILE} in place"
    continue;
  elif [[ -d "${HOME}/.${DOTFILE}" ]]; then
    echo "WARNING: Leaving .${DOTFILE} in place"
    continue;
  elif [[ -f "${HOME}/.${DOTFILE}" ]]; then
    bash -v -c "mv '${HOME}/.${DOTFILE}' '${HOME}/.${DOTFILE}-${TIMESTAMP}'";
  fi
  bash -v -c "ln -s '${HOME}/.local/dotfiles/${DOTFILE}' '${HOME}/.${DOTFILE}'";
done
