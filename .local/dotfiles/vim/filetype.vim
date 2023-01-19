" filetypes.vim
" This file goes in $VIMHOME and assumes you are using vim6.0 or better. Also
" place syntax there.
" % module rm vim
" % module add vim/6.0.237

:augroup syntax
  " Clear all autocommands for this group
  autocmd!
augroup END

:augroup filetype
  autocmd!
  autocmd  BufReadPost  * if getline(1) =~ "(@)END" | $ | endif
  autocmd BufWritePost  * source $VIMHOME/scripts/lint.vim
augroup END

"TAF!
