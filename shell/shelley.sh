
if [ "$NVIM_LISTEN_ADDRESS" = "" ] ; then
    return
fi

export PATH="$PATH:$(dirname $0)/../python"

if [ "$(basename $SHELL)" = "zsh" ] ; then
    source "$(dirname $0)/shelley.zsh"
fi
