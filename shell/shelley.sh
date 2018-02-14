
if [ "$NVIM_LISTEN_ADDRESS" = "" ] ; then
    return
fi

export PATH="$(dirname $0)/../python:$PATH"

if [ "$(basename $SHELL)" = "zsh" ] ; then
    source "$(dirname $0)/shelley.zsh"
fi
