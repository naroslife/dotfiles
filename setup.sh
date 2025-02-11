#!/usr/bin/env bash
stow .
echo retek $( dirname -- "$( readlink -f -- "$0"; )"; ) retek "$0"
ln -sf $( dirname -- "$( readlink -f -- "$0"; )"; )/.bashrc ~/.bashrc
ln -sf $( dirname -- "$( readlink -f -- "$0"; )"; )/.bash_completion ~/.bash_completion
ln -sf $( dirname -- "$( readlink -f -- "$0"; )"; )/.profile ~/.profile
ln -sf $( dirname -- "$( readlink -f -- "$0"; )"; )/.tool-versions ~/.tool-versions
ln -sf $( dirname -- "$( readlink -f -- "$0"; )"; )/starship/starship.toml ~/.config/starship.toml
