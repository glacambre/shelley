" shelley.vim - Further integrate your shell into neovim
" Maintainer:   Ghjuvan Lacambre
" Version:      0.1
" Licence:      Public Domain

if exists("g:loaded_shelley")
  finish
endif
let g:loaded_shelley = 1

if !exists("g:shelley_noman")
  let g:shelley_noman = 0
endif

if !exists("g:shelley_nocd")
  let g:shelley_nocd = 0
endif

if !exists("g:shelley_noprompt")
  let g:shelley_noprompt = 0
endif

" Called when a new term is created
function! shelley#OnTermOpen()
  au BufEnter <buffer> if exists("g:shelley_nocd") && g:shelley_nocd != 1 && exists("b:shelley_path")
        \| execute("cd " . b:shelley_path)
        \| endif
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
    if !exists('b:shelley_prompts') || !exists('b:shelley_ps1') || !exists('b:shelley_heights')
        let b:shelley_prompts = []
        let b:shelley_ps1 = {}
        let b:shelley_heights = {}
    endif

    let b:shelley_prompts += [prompt_line]
    let b:shelley_ps1["" . prompt_line] = len(substitute(a:ps1, '\[[^m]\+m', '', 'g'))
    let b:shelley_heights["" . prompt_line] = a:cmdheight

    " Go back to the buffer we were on before calling the function
    exe "buffer " . curbuf
endfunction

" Returns the line number for the next/previous prompt
" a:prompts is the list of prompts
" a:curline is the line number the cursor is currently sitting on
" a:prev is 1 if the function should return the previous prompt, 0 if it
"        should return the next
" Returns -1 if there is no previous/next prompt
function! shelley#GetPromptIndex(prompts, curline, prev)
    let i = 0
    while i < len(a:prompts) && a:prompts[i] < a:curline
        let i += 1
    endwhile
    if a:prev
        return i - 1
    endif
    if i >= len(a:prompts)
        return -1
    endif
    if a:curline == a:prompts[i] && i == (len(a:prompts) - 1)
        return -1
    endif
    return i + (a:curline == a:prompts[i])
endfunction

" Goes to the next/previous term prompt
" prev: 1 if we want the previous prompt, 0 if we want the next
function! shelley#TermPrompt(prev) abort range
    if !exists('b:shelley_prompts') || !exists('b:shelley_ps1')
        return
    endif

    let curline = line('.')
    let i = shelley#GetPromptIndex(b:shelley_prompts, curline, a:prev)

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

" Returns a text object matching the spec required by vim-textobj-user
" If inner is 1, the region corresponds to the output of a command
" If inner is 0, the region is the output of a command + the command
function! shelley#SelectOutput(inner)
    let [bufnum, cur_line, cur_col, off] = getpos('.')
    let prev_prompt = shelley#GetPromptIndex(b:shelley_prompts, cur_line, 1)
    let next_prompt = shelley#GetPromptIndex(b:shelley_prompts, cur_line, 0)
    if prev_prompt < 0 || next_prompt < 0
        return 0
    endif
    " This happens when the cursor is already sitting on a prompt line
    if next_prompt != prev_prompt + 1
        prev_prompt = next_prompt - 1
    endif

    let prev_line = b:shelley_prompts[prev_prompt]
    if a:inner == 1
        let prev_line += b:shelley_heights["" + prev_line]
        let prev_line += 1
    endif

    let next_line = b:shelley_prompts[next_prompt] - 1

    let rstart = [bufnum,  prev_line, 1, 0]
    let rend = [bufnum, next_line, strwidth(getline(next_line)) , 0]

    return ['v', rstart, rend]
endfunction

function! shelley#SelectIOutput()
    return shelley#SelectOutput(1)
endfunction

function! shelley#SelectAOutput()
    return shelley#SelectOutput(0)
endfunction

if exists("*textobj#user#plugin()") && g:shelley_notextobj != 1
    call textobj#user#plugin('output', {
        \ '-': {
        \       'select-a-function': 'shelley#SelectAOutput',
        \       'select-a': 'ao',
        \       'select-i-function': 'shelley#SelectIOutput',
        \       'select-i': 'io',
        \ },
    \ })
endif

augroup shelley
    autocmd!
    autocmd TermOpen * silent call shelley#OnTermOpen()
augroup END
