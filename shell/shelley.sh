
if [ "$NVIM_LISTEN_ADDRESS" = "" ] ; then
    return
fi

if [ "$(basename $SHELL)" = "zsh" ] ; then
    source "$(dirname $0)/shelley.zsh"
fi
