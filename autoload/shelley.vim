" shelley.vim - Further integrate your shell into neovim
" Maintainer:   Ghjuvan Lacambre
" Version:      0.1
" Licence:      Public Domain

function! shelley#InitBuffer()
    let b:shelley = {}
    let b:shelley["prompts"] = []
    let b:shelley["ps1"] = {}
    let b:shelley["heights"] = {}
    let b:shelley["path"] = ""
    let b:shelley["last_line"] = line('$')
endfunction

" Called when a new term is created
function! shelley#OnTermOpen()
    if !exists("b:shelley")
      call shelley#InitBuffer()
    endif
    au BufEnter <buffer> if !get(g:shelley, "nocd", 0)
          \| execute("cd " . b:shelley["path"])
          \| endif
endfunction

function! shelley#GetBuf(pid)
    let allbufs = getbufinfo()
    " Find the buffer that belongs to the shell that has pid a:pid
    let bufnr = -1
    for i in range(len(allbufs))
        if get(allbufs[i]["variables"], "terminal_job_pid", 0) == a:pid
            let bufnr = allbufs[i]["bufnr"]
            break
        endif
    endfor
    return bufnr
endfunction

function! shelley#PreCmd(pid)
    let termbuf = shelley#GetBuf(a:pid)
    if termbuf == - 1
      return
    endif

    let curbuf = bufnr("%")
    exe "buffer " . termbuf

    if !exists("b:shelley")
        call shelley#InitBuffer()
    endif

    try
        $;?.
        let b:shelley["last_line"] = line(".")
    catch
        let b:shelley["last_line"] = line("$")
    endtry

    exe "buffer " . curbuf
endfunction

" Saves the prompt position
" pid: The pid of the shell that should be saved
" ps1: The PS1, can contain escape sequences
" cmdheight: The height of the command line
function! shelley#PreExec(pid, ps1, cmdheight) abort
    let termbuf = shelley#GetBuf(a:pid)
    if termbuf == -1
        return
    endif

    let curbuf = bufnr("%")
    " Go to shell buffer
    exe "buffer " . termbuf

    if !exists("b:shelley")
        call shelley#InitBuffer()
    endif

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

    let b:shelley["prompts"] += [prompt_line]
    let b:shelley["ps1"]["" . prompt_line] = len(substitute(a:ps1, '\[[^m]\+m', '', 'g'))
    let b:shelley["heights"]["" . prompt_line] = a:cmdheight

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
    if &buftype != "terminal" || !exists('b:shelley')
        return
    endif

    let curline = line('.')
    let i = shelley#GetPromptIndex(b:shelley["prompts"], curline, a:prev)

    let action = ""
    if (i >= 0 && i < len(b:shelley["prompts"]))
        " Compute how many lines the cursor should be moved {horizonta,vertica}lly
        let target_line = b:shelley["prompts"][i]
        let target_col = b:shelley["ps1"]["" + target_line]

        let lcount = (target_line - curline)
        if lcount > 0
            let action = lcount . "j"
        elseif lcount < 0
            let action = (-lcount) . "k"
        endif

        let action .= "0" . target_col . "l"
    endif
    echo action

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
    if !exists('b:shelley')
        return
    endif
    let [bufnum, cur_line, cur_col, off] = getpos('.')

    let next_prompt = shelley#GetPromptIndex(b:shelley["prompts"], cur_line, 0)
    if next_prompt >= 0
      let next_line = b:shelley["prompts"][next_prompt] - 1
    else
      let next_prompt = len(b:shelley["prompts"])
      let next_line = b:shelley["last_line"]
    endif

    let prev_prompt = next_prompt - 1
    if prev_prompt < 0
        return 0
    endif

    " Get the line number for the prev_prompt-th prompt
    let prev_line = b:shelley["prompts"][prev_prompt]
    if a:inner == 1
        let prev_line += b:shelley["heights"]["" + prev_line]
        let prev_line += 1
    endif


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

if exists("*textobj#user#plugin()") && !get(g:shelley, "notextobj", 0)
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
