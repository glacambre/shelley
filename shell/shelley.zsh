
SHELLEY_BIN="$(dirname $0)/../python/shelley"

if [[ ! -v preexec_functions ]]; then
    preexec_functions=()
fi

if [[ ! -v precmd_functions ]]; then
    precmd_functions=()
fi

function shelley_preexec() {
    # Note: if this breaks, try ${{(%)${(e)PS1}}}
    "$SHELLEY_BIN" --preexec "$$" "${(%e)PS1}" "$1"
}
preexec_functions+=shelley_preexec

function shelley_precmd() {
    "$SHELLEY_BIN" --precmd "$$"
}
precmd_functions+=shelley_precmd
