
SHELLEY_BIN="$(dirname $0)/../python/shelley"

if [[ "$(echo $ZSH_VERSION | cut -d. -f1,2)" -gt 5.2 ]]; then
    if [[ ! -v preexec_functions ]]; then
	preexec_functions=()
    fi

    if [[ ! -v chpwd_functions ]]; then
	chpwd_functions=()
    fi

    if [[ ! -v precmd_functions ]]; then
	precmd_functions=()
    fi
fi

function shelley_man () {
    if [[ "$SHELLEY_NOMAN" = "" || "$SHELLEY_NOMAN" = "0" ]] ; then
	"$SHELLEY_BIN" --man $@
    else
	command man $@
    fi
}
alias man='shelley_man'

# automatically change working dir of parent buffer if using zsh within nvim
function shelley_cd () {
    emulate -L zsh
    if [[ "$SHELLEY_NOCD" = "" || "$SHELLEY_NOCD" = "0" ]] ; then
	"$SHELLEY_BIN" --cd "$(pwd)"
    fi
}
if [[ "$SHELLEY_NOCD" = "" || "$SHELLEY_NOCD" = "0" ]] ; then
    (shelley_cd &) >/dev/null
fi
chpwd_functions+=shelley_cd

function shelley_preexec() {
    # Note: if this breaks, try ${{(%)${(e)PS1}}}
    if [[ "$SHELLEY_NOPROMPT" = "" || "$SHELLEY_NOPROMPT" = "0" ]] ; then
	"$SHELLEY_BIN" --preexec "$$" "${(%e)PS1}" "$1"
    fi
}
preexec_functions+=shelley_preexec

function shelley_precmd() {
    if [[ "$SHELLEY_NOPROMPT" = "" || "$SHELLEY_NOPROMPT" = "0" ]] ; then
	"$SHELLEY_BIN" --precmd "$$"
    fi
}
precmd_functions+=shelley_precmd
