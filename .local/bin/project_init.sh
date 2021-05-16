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
    echo "INFO: Backup ${HOME}/.${DOTFILE}-${TIMESTAMP}";
    mv "${HOME}/.${DOTFILE}" "${HOME}/.${DOTFILE}-${TIMESTAMP}";
  fi
  echo "INFO: Linking ${HOME}/.${DOTFILE}-${TIMESTAMP}";
  ln -s "${HOME}/.local/dotfiles/${DOTFILE}" "${HOME}/.${DOTFILE}"
done
