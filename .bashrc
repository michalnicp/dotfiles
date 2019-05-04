# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# aliases
alias tmux='TERM=xterm-256color tmux'

# environment variables

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"

if [ -f ${XDG_CONFIG_HOME}/user-dirs.dirs ]; then
    . ${XDG_CONFIG_HOME}/user-dirs.dirs
    export XDG_DESKTOP_DIR
    export XDG_DOWNLOAD_DIR
    export XDG_TEMPLATES_DIR
    export XDG_PUBLICSHARE_DIR
    export XDG_DOCUMENTS_DIR
    export XDG_MUSIC_DIR
    export XDG_PICTURES_DIR
    export XDG_VIDEOS_DIR
fi
