" shelley.vim - Further integrate your shell into neovim
" Maintainer:   Ghjuvan Lacambre
" Version:      0.1
" Licence:      Public Domain

if exists("g:loaded_shelley")
  finish
endif
let g:loaded_shelley = 1

if !exists("g:shelley")
  let g:shelley = {}
endif
