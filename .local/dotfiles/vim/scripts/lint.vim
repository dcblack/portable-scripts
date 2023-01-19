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
    shellcheck-vim -P "${HOME}" -xa -o all %
  endif

  if b:current_syntax == "zsh"
    echo "Linting zsh"
    shellcheck-vim -P "${HOME}" -xa -o all -s bash %
  endif

  if b:current_syntax == "sh"
    echo "Linting shell"
    shellcheck-vim -P "${HOME}" -xa -o all %
  endif

  if b:current_syntax == "html"
    echo "Linting HTML"
    compiler tidy
    make
  endif

endif

"EOF
