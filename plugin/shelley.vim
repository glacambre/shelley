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

let g:shelley["noman"] = get(g:shelley, "noman", 0)
let g:shelley["nocd"] = get(g:shelley, "nocd", 0)
let g:shelley["noprompt"] = get(g:shelley, "noprompt", 0)
let g:shelley["notextobj"] = get(g:shelley, "notextobj", 0)
