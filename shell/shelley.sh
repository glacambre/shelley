
if [ "$NVIM_LISTEN_ADDRESS" = "" ] ; then
    return
fi

if ! [ "$ZSH_VERSION" = "" ] ; then
    source "$(dirname $0)/shelley.zsh"
fi
