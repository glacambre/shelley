" shelley.vim - Further integrate your shell into neovim
" Maintainer:   Ghjuvan Lacambre
" Version:      0.1
" Licence:      Public Domain

if exists("g:loaded_shelley")
  finish
endif
let g:loaded_shelley = 1

" Called when a new term is created
function! shelley#OnTermOpen()
  au BufEnter <buffer> if exists("b:shelley_path") | execute("cd " . b:shelley_path) | endif
endfunction

" Saves the prompt position
" pid: The pid of the shell that should be saved
" from_precmd: 1 if called from a precmd zsh hook, 0 otherwise
" ps1: The PS1, can contain escape sequences
" cmdheight: The height of the command line
function! shelley#SavePrompt(pid, from_precmd, ps1, cmdheight) abort
    let allbufs = getbufinfo()
    " Find the buffer that belongs to the shell that has pid a:pid
    let bufnr = 0
    for i in range(len(allbufs))
        if get(allbufs[i]["variables"], "terminal_job_pid", 0) == a:pid
            let bufnr = allbufs[i]["bufnr"]
            break
        endif
    endfor
    if bufnr == 0
        return
    endif

    " Save currently selected buffer
    let curbuf = bufnr("%")
    " Go to shell buffer
    exe "buffer " . bufnr

    let prompt_line = 1
    " Try to find the last line with text
    try
        $;?.
        let prompt_line = line('.')
    catch
        " Fails if the buffer is empty
        let prompt_line = 1
    endtry
    let prompt_line = (prompt_line - a:cmdheight)

    " Save current cursor line and ps1
    if !exists('b:shelley_prompts') || !exists('b:shelley_ps1')
        let b:shelley_prompts = []
        let b:shelley_ps1 = {}
    endif

    let b:shelley_prompts += [prompt_line]
    let b:shelley_ps1["" . b:shelley_prompts[-1]] = len(substitute(a:ps1, '\[[^m]\+m', '', 'g'))

    " Go back to the buffer we were on before calling the function
    exe "buffer " . curbuf
endfunction

" Goes to the next/previous term prompt
" prev: 1 if we want the previous prompt, 0 if we want the next
function! shelley#TermPrompt(prev) abort range
    if !exists('b:shelley_prompts') || !exists('b:shelley_ps1')
        return
    endif

    " Find the prompt line after the cursor
    let curline = line('.')
    let i = 0
    while i < len(b:shelley_prompts) && (b:shelley_prompts[i]) < curline
        let i += 1
    endwhile

    if a:prev
        let i = i - 1
    else
        " If the cursor is already on prompt, get the next one
        let i += i < len(b:shelley_prompts) && b:shelley_prompts[i] == curline
    endif

    let action = ""
    if (i >= 0 && i < len(b:shelley_prompts)) 
        " Compute how many lines the cursor should be moved {horizonta,vertica}lly
        let target_line = b:shelley_prompts[i]
        let target_col = b:shelley_ps1["" + target_line] + 1

        let lcount = (target_line - curline)
        if lcount > 0
            let action = lcount . "j"
        elseif lcount < 0
            let action = (-lcount) . "k"
        endif

        let ccount = (target_col - col('.'))
        if ccount > 0
            let action .= ccount . "l"
        elseif ccount < 0
            let action .= (-ccount) . "h"
        endif
    endif
    return action
endfunction

function! shelley#NextPrompt()
  return shelley#TermPrompt(0)
endfunction

function! shelley#PrevPrompt()
  return shelley#TermPrompt(1)
endfunction

augroup shelley
  autocmd!
  autocmd TermOpen * silent call shelley#OnTermOpen()
augroup END
