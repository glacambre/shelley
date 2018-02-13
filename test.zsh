
dir="$(pwd)/$(dirname $0)"
printf "aexport PATH=\"${dir}/python:\$PATH\"\nsource ${dir}/shell/nvim_shelley_zsh\n" | \
	nvim -u NORC \
		--cmd "source ${dir}/autoload/shelley.vim" \
		--cmd "nnoremap <expr> b shelley#PrevPrompt()" \
		term://"zsh -f"
