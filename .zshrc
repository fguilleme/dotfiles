# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="fguilleme"
#ZSH_THEME="kphoen"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git colorize zsh-history-substring-search per-directory-history zsh-navigation-tools)

export ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh


export LD_LIBRARY_PATH=/home/francois/lib

unsetopt correct_all
setopt histignorespace
setopt histignoredups
setopt noautocd

# some more ls aliases
alias ll='ls -Al'
alias la='ls -A'
alias l='ls -CF'

#  for git not to warn about locales
alias git='LC_ALL=fr_FR.UTF-8 \git'

# do not share history between zsh invocations
unsetopt share_history

setopt nohashdirs
setopt nohashcmds

# bind META-. to insert the last argument of previous command
bindkey '^[' vi-cmd-mode
# bindkey "^[." insert-last-word

# longer timeout I am not a fast typer
export KEYTIMEOUT=1

# bind up/down to search through history
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# bind CTRL-W to erase last word including /
function _backward_kill_default_word() {
  WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' zle backward-kill-word
}
zle -N backward-kill-default-word _backward_kill_default_word
bindkey '^W' backward-kill-default-word   # = is next to backspace

# helper command to create a temp dir and cd into
function mkcd {
#    mkdir "$(date +%D_%T | tr /: __)" && cd $_
    mkdir "$(date +%Y%m%d_%H%M%S | tr /: __)" && cd $_
}

export EDITOR=nvim
export SHELL=/usr/bin/zsh

# autoload -U select-word-style
# select-word-style bash

# lazy man aliases
alias r=ranger
alias R='sudo -E ranger'

alias atop="adb shell dumpsys activity top"
capture() {
    adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > $1.png
}
alias capture=capture
setLocale() {
    adb shell "su -c 'setprop persist.sy.language $1; setprop persist.sys.country $2; stop; sleep 5; start'"
}
alias setLocale=setLocale
#export REPORTTIME=3

# helper do hexdump a file w/less
xx() { hexdump -C $* | less }
UU() { sudo apt update && sudo apt dist-upgrade -y }

export PATH=~/bin:/sbin:/usr/sbin:${PATH}
export PATH=~/Android/Sdk/platform-tools:~/Android/Sdk/tools:${PATH}
export PATH=~/.cabal/bin:$PATH
export PATH=~/node/bin:$PATH

source ~/dotfiles/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--preview='~/.config/ranger/scope.sh {}'"
export FZF_DEFAULT_COMMAND='rg --files --ignore-case --hidden -g "!{.git,node_modules,vendor}/*"'

fpath+=${ZDOTDIR:-~}/.zsh_functions

export LD_PRELOAD=/lib/x86_64-linux-gnu/libSegFault.so 
export SEGFAULT_SIGNALS="abrt segv fpe" 

export TERM=st-256color         # allacrity set a custom TERM so if we connect to another host wihou it it goes nuts
alias vi=nvim
alias vim=nvim

# set a random background for a specific screen or both
set_ss() {
  echo ${1:-$(shuf -i0-1)} | xargs  -n1  -I{} -- nitrogen --set-zoom-fill --random --head={}
}
alias sss=set_ss $*

# needed to start ssh key daemon under awesome-wm
eval $(gnome-keyring-daemon -c ssh -r 2> /dev/null)

source ~/bin/macho.sh
