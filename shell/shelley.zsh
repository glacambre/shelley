
if [[ ! -v preexec_functions ]]; then
    preexec_functions=()
fi

if [[ ! -v chpwd_functions ]]; then
    chpwd_functions=()
fi

if [[ ! -v precmd_functions ]]; then
    precmd_functions=()
fi

function zsh_nvim_shelley_man () {
    if [ "$SHELLEY_NOMAN" != "1" ] ; then
	nvim_shelley_man $@
    else
	command man $@
    fi
}
alias man='zsh_nvim_shelley_man'

# automatically change working dir of parent buffer if using zsh within nvim
function zsh_nvim_shelley_cd () {
    emulate -L zsh
    if [[ "$SHELLEY_NOCD" != "1" ]] ; then
	nvim_shelley_cd "$(pwd)"
    fi
}
if [[ "$SHELLEY_NOCD" != "1" ]] ; then
    (zsh_nvim_shelley_cd &) >/dev/null
fi
chpwd_functions+=zsh_nvim_shelley_cd

function zsh_nvim_shelley_saveprompt() {
    # Note: if this breaks, try ${{(%)${(e)PS1}}}
    if [[ "$SHELLEY_NOPROMPT" != "1" ]] ; then
	nvim_shelley_saveprompt "$$" "${(%e)PS1}" "$1"
    fi
}
preexec_functions+=zsh_nvim_shelley_saveprompt

function zsh_shelley_precmd() {
    if [[ "$SHELLEY_NOPROMPT" != "1" ]] ; then
	nvim_shelley_precmd "$$"
    fi
}
precmd_functions+=zsh_shelley_precmd
