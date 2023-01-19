" This script is run when files are written and should be used to do
" light-weight syntax check of various languages.

if exists("syntax_on") && exists("b:current_syntax")

  if b:current_syntax == "perl"
    echo "Linting PERL"
    compiler perl
    make
  endif

  if b:current_syntax == "bash"
    echo "Linting bash"
    !~/bin/shellcheck-vim -P "${HOME}" -xa -o all %
  endif

  if b:current_syntax == "zsh"
    echo "Linting zsh"
    !~/bin/shellcheck-vim -P "${HOME}" -xa -o all -s bash %
  endif

  if b:current_syntax == "sh"
    echo "Linting shell"
    !~/bin/shellcheck-vim -P "${HOME}" -xa -o all %
  endif

  if b:current_syntax == "html"
    echo "Linting HTML"
    compiler tidy
    make
  endif

endif

"EOF
