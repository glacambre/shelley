# Shelley - Better integrate your shell into neovim

## Presentation
Shelley lets you:
- Automatically cd neovim wherever you cd with your shell

- Automatically use neovim's `:Man` when you use "man", thus allowing you to
  read the manual

- Remember where your prompts are in the terminal buffer and easily move
  between them with a single key binding

- If [vim-textobj-user](https://github.com/kana/vim-textobj-user) is installed,
  create "io" and "ao" text objects to select/copy a command's output with or
  without the command

Here is a brief demonstration of Shelley:
[https://asciinema.org/a/163184](https://asciinema.org/a/163184)


## How to install
### Requirements
Shelley currently only works with zsh. It also needs
[vim-textobj-user](https://github.com/kana/vim-textobj-user) to be installed if
you want the command text objects to be enabled.

### Get shelley
Use [your](https://github.com/tpope/vim-pathogen)
[favorite](https://github.com/Shougo/dein.vim)
[plugin](https://github.com/VundleVim/Vundle.vim)
[manager](https://github.com/junegunn/vim-plug) to install shelley.

Then, add the following line to your `~/.zshrc`:
```sh
source PATH/TO/THE/CLONED/REPOSITORY/shelley/shell/shelley.sh
```
If nothing went wrong, Shelley should be installed now.


## Settings
- Using the host's `:Man` can be disabled by either adding `export
  SHELLEY_NOMAN=1` to your .zshrc or by adding `let g:shelley['noman']=1` to
  your init.vim

- Automatic cd can be disabled by either adding `export SHELLEY_NOCD=1` to your
  .zshrc or by adding `let g:shelley['nocd']=1` to your init.vim

- Prompt saving can be disabled by either adding `export SHELLEY_NOPROMPT` to
  your .zshrc or by adding `let g:shelley['noprompt']=1` to your init.vim

- Default mappings to navigate from a prompt to another aren't provided.
  Instead you need to create your own by doing something like this:
```vimscript
nnoremap <expr> <Space>p shelley#PrevPrompt()
nnoremap <expr> <Space>n shelley#NextPrompt()
vnoremap <expr> <Space>p shelley#PrevPrompt()
vnoremap <expr> <Space>n shelley#NextPrompt()
```

- Command text objects are created by default and bound to o.This means that
  you can select a command's output with `vio` or copy a command and its output
  with `yao`. If you don't want text objects to be created by default, add `let
  g:shelley['notextobj']=1` to your init.vim.


## Bugs
- I didn't test shelley with zsh's RPROMPT feature but I don't think it'd go
  well. Same thing for multi-line $PS1. If there are bugs they probably could
  easily be fixed though.

- If your shell buffer gets longer than your scrollback value (see `:h
  scrollback`), shelley will lose track of your prompts. This happens because
  there currently is no non-hackish way to know how many lines are discarded by
  neovim. A partial workaround is to `set scrollback = -1`.

## Other terminal-centric plugins
- [Neoterm](https://github.com/kassio/neoterm): make repls easier to use with
  Neovim

- [Deol](https://github.com/Shougo/deol.nvim): Use a normal neovim buffer as a
  terminal emulator for your shell


Feel free to open an issue if you encounter an issue with Shelley :).
