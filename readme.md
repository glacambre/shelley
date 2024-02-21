# DISCONTINUED

I implemented [OSC autocommands in neovim](https://github.com/neovim/neovim/pull/22159).
This means that you can now trivially [synchronize your terminal working
directories](https://lacamb.re/blog/osc7_in_neovim_third_time.html#scripting-osc7-support)
and create commands to [jump from prompt to prompt](https://github.com/neovim/neovim/issues/9209#issuecomment-1956018035).

Thus, you should not use Shelley anymore. Thank you for your interest though!

## Shelley - Better integrate your shell into neovim

Shelley creates text objects to select prompts/command outputs and provides
functions to navigate from prompt to prompt in terminal buffers.

It requires https://github.com/kana/vim-textobj-user to be installed. Shelley
is both a neovim and a zsh plugin. Install it with your favorite neovim plugin
and then source `shelley/shell/shelley.sh` from your .zshrc.

Default mappings to navigate from a prompt to another aren't provided. Instead
you need to create your own by doing something like this:
```vimscript
nnoremap <expr> <Space>p shelley#PrevPrompt()
nnoremap <expr> <Space>n shelley#NextPrompt()
vnoremap <expr> <Space>p shelley#PrevPrompt()
vnoremap <expr> <Space>n shelley#NextPrompt()
```

- Command text objects are created by default and bound to o. This means that
  you can select a command's output with `vio` or copy a command and its output
  with `yao`.


### Bugs
- I didn't test Shelley with zsh's RPROMPT feature but I don't think it'd go
  well. Same thing for multi-line $PS1. If there are bugs they probably could
  easily be fixed though.

- If your shell buffer gets longer than your scrollback value (see `:h
  scrollback`), Shelley will lose track of your prompts. This happens because
  there currently is no non-hackish way to know how many lines are discarded by
  neovim. A partial workaround is to `set scrollback = -1`.
