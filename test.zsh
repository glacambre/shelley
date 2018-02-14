
dir="$(pwd)/$(dirname $0)"
printf ":set rtp+=${dir}
:nnoremap <expr> b shelley#PrevPrompt()
:nnoremap <expr> a shelley#NextPrompt()
:helptags doc
isource ${dir}/shell/shelley.sh\n" | nvim -u NORC term://"zsh -f"
