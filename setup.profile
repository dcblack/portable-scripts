#!/bin/bash

# Where to install
LOCAL="${HOME}/.local"
APPS="${LOCAL}/apps"
DOTBIN="${LOCAL}/bin"
APPSBIN="${LOCAL}/apps/bin"
TEMPLATEPATH="${HOME}/templates"
export LOCAL APPS DOTBIN APPSBIN TEMPLATEPATH

# shellcheck disable=SC2164
pushd "${HOME}"
if [[ -d portable-scripts ]]; then
  # shellcheck disable=SC2164
  pushd portable-scripts
  git pull
  # shellcheck disable=SC2164
  popd
else
  git clone https://github.com/dcblack/portable-scripts.git
fi
if [[ -L .local ]]; then
  echo "Leaving existing .local in place"
else
  ln -s "${HOME}/portable-scripts/.local" "${LOCAL}"
fi

function unique_path() {
  # USAGE: unique_path VAR
  local PERL_SCRIPT
  PERL_SCRIPT='
    $v=$ARGV[0];
    for my $d(split(qr":",$ENV{$v})){
      next if !-d $d;
      $e=abs_path($d);
      if( ! exists $e{$e} ){
        $e{$e}=1;
        push(@e,$e);
      }
    }
    printf qq{%s="%s"\n},$v,join(":",@e);
  '
  eval $(perl -M'Cwd(abs_path)' -e "${PERL_SCRIPT}" "$1")
}

PATH="${DOTBIN}:${APPSBIN}:${PATH}"
unique_path PATH
for f in "${APPS}/sc-templates"; do
  if [[ -d "${f}" ]]; then
    TEMPLATEPATH="${TEMPLATEPATH}:${f}"
  fi
done
unique_path TEMPLATEPATH
# shellcheck disable=SC2164
popd

#vim:nospell
