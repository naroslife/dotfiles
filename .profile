# # ~/.profile: executed by the command interpreter for login shells.
# # This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# # exists.
# # see /usr/share/doc/bash/examples/startup-files for examples.
# # the files are located in the bash-doc package.

# # the default umask is set in /etc/profile; for setting the umask
# # for ssh logins, install and configure the libpam-umask package.
# #umask 022
# export PATHS_SET=false
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

# if [ -d "$HOME/.local/usr/bin" ] ; then
#     export PATH="$HOME/.local/usr/bin:$PATH"
# fi
# if [ -d "/home/commondev/.local/usr/bin" ] ; then
#     export PATH="/home/commondev/.local/usr/bin:$PATH"
# fi
# export PATHS_SET=true

# # if running bash
# if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
#     # include .bashrc if it exists
#     if [ -f "$HOME/.bashrc" ]; then
#     source "$HOME/.bashrc"
#     fi
# fi

# . "$HOME/.atuin/bin/env"
# . "$HOME/.cargo/env"

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
