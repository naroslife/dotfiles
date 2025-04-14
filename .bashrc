# # ~/.bashrc: executed by bash(1) for non-login shells.
# # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# # for examples
# # /bin/bash /home/naroslife/retek2_retek3_retek1/.vscode/dockersetup.sh
# if [ -z "$ISDOCKER" ]; then
#     # If not running interactively, don't do anything
#     case $- in
#         *i*) ;;
#         *) return;;
#     esac
# fi

# source ~/dotfiles/base/lib/stdlib.sh
# # don't put duplicate lines or lines starting with space in the history.
# # See bash(1) for more options
# HISTCONTROL=ignoreboth

# # append to the history file, don't overwrite it
# shopt -s histappend

# # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# HISTSIZE=1000
# HISTFILESIZE=2000

# # check the window size after each command and, if necessary,
# # update the values of LINES and COLUMNS.
# shopt -s checkwinsize

# # If set, the pattern "**" used in a pathname expansion context will
# # match all files and zero or more directories and subdirectories.
# #shopt -s globstar
source "$HOME/.sdkman/bin/sdkman-init.sh"
# # make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# # set variable identifying the chroot you work in (used in the prompt below)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi

# # set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
#     xterm-color|*-256color) color_prompt=yes;;
# esac

# # Alias definitions.
# # You may want to put all your additions into a separate file like
# # ~/.bash_aliases, instead of adding them here directly.
# # See /usr/share/doc/bash-doc/examples in the bash-doc package.

# if [ -f ~/.bash_aliases ]; then
#     . ~/.bash_aliases
# fi

# # enable programmable completion features (you don't need to enable
# # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# # sources /etc/bash.bashrc).
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi

# # set PATH so it includes user's private bin if it exists
# if [ -d "$HOME/bin" ] ; then
#     export PATH="$HOME/bin:$PATH"
# fi
# # set PATH so it includes user's private bin if it exists
# if [ -d "$HOME/.local/bin" ] ; then
#     export PATH="$HOME/.local/bin:$PATH"
# fi
# if [ -d "/home/commondev/.local/bin" ] ; then
#     export PATH="/home/commondev/.local/bin:$PATH"
# fi

# if [ -d "/home/commondev/.local/usr/lib" ] ; then
#     export LD_LIBRARY_PATH="/home/commondev/.local/usr/lib:$LD_LIBRARY_PATH"
# fi
# if [ -d "/home/commondev/.local/usr/lib/x86_64-linux-gnu" ] ; then
#     export LD_LIBRARY_PATH="/home/commondev/.local/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
# fi

# if [ -d "$HOME/.local/usr/bin" ] ; then
#     export PATH="$HOME/.local/usr/bin:$PATH"
# fi
# if [ -d "/home/commondev/.local/usr/bin" ] ; then
#     export PATH="/home/commondev/.local/usr/bin:$PATH"
# fi
# if [ -d "/home/naroslife/retek2_retek3_retek1/scripts" ] ; then
#     export PATH="/home/naroslife/retek2_retek3_retek1/scripts:$PATH"
# fi
# if [ -d "/home/naroslife/nvim-linux64/bin" ] ; then
#     export PATH="/home/naroslife/nvim-linux64/bin:$PATH"
# fi
# # dedupe_path


# . "$HOME/.cargo/env"


# export VSCODE="true"
# export NVM_DIR="$HOME/.nvm"
# if ! command -v code &> /dev/null
# then
#     print_info "VSCode not found, using Neovim as default editor"
#     export EDITOR='nvim'
# else
#     print_info "VSCode found, using it as default editor"
#     export EDITOR='code'
# fi


# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# eval "$(zoxide init bash)"
# eval "$(starship init bash)"

# if [ "$LC_SWITCHTO" = "elvish" ]; then
#     print_info "Switching to elvish..." && exec elvish
# elif [ "$LC_SWITCHTO" = "inshellisense" ]; then
#     print_info "Loading inshellisense..."
#     if [[ -z "${ISTERM}" && $- = *i* && $- != *c* ]]; then
#         shopt -q login_shell
#         login_shell=$?
#         if [ $login_shell -eq 0 ]; then
#             is -s bash --login ; exit
#         else
#             is -s bash ; exit
#         fi 
#     fi
# fi  

# . "$HOME/.atuin/bin/env"
# . $HOME/.asdf/asdf.sh
# eval $(thefuck --alias)

# #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# . $HOME/.asdf/asdf.sh
# eval $(thefuck --alias)
# . $HOME/.asdf/asdf.sh
# eval $(thefuck --alias)
# source /usr/local/lib/stdlib.sh
