# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# bindkey -e
# export XDG_CONFIG_HOME="$HOME/.config"
# export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"


# zstyle ':completion:*' auto-description 'specify: %d'
# zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
# zstyle ':completion:*' completions 1
# zstyle ':completion:*' format 'Completing %d:'
# zstyle ':completion:*' glob 1
# zstyle ':completion:*' group-name ''

# zstyle ':completion:*:parameters'  list-colors '=*=32'
# zstyle ':completion:*:commands' list-colors '=*=1;31'
# zstyle ':completion:*:builtins' list-colors '=*=1;38;5;142'
# zstyle ':completion:*:aliases' list-colors '=*=2;38;5;128'
# zstyle ':completion:*:*:kill:*' list-colors '=(#b) #([0-9]#)*( *[a-z])*=34=31=33'
# zstyle ':completion:*:options' list-colors '=^(-- *)=34'
# zstyle ':completion:*:options' list-colors '${(s.:.)LS_COLORS}'


# zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
# zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
# zstyle ':completion:*' max-errors 2 numeric
# zstyle ':completion:*' menu select=1
# zstyle ':completion:*' prompt 'Correcting %e error(s):'
# zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
# zstyle ':completion:*' substitute 1
# zstyle ':completion:*' verbose true
# zstyle :compinstall filename '/home/naroslife/.zshrc'


# # If you come from bash you might have to change your $PATH.
# # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# # Path to your Oh My Zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

# # Set name of the theme to load --- if set to "random", it will
# # load a random theme each time Oh My Zsh is loaded, in which case,
# # to know which specific one was loaded, run: echo $RANDOM_THEME
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"

# # Set list of themes to pick from when loading at random
# # Setting this variable when ZSH_THEME=random will cause zsh to load
# # a theme from this variable instead of looking in $ZSH/themes/
# # If set to an empty array, this variable will have no effect.
# # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# # Uncomment the following line to use case-sensitive completion.
# # CASE_SENSITIVE="true"

# # Uncomment the following line to use hyphen-insensitive completion.
# # Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# # Uncomment one of the following lines to change the auto-update behavior
# # zstyle ':omz:update' mode disabled  # disable automatic updates
# # zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# # Uncomment the following line to change how often to auto-update (in days).
# # zstyle ':omz:update' frequency 13

# # Uncomment the following line if pasting URLs and other text is messed up.
# # DISABLE_MAGIC_FUNCTIONS="true"

# # Uncomment the following line to disable colors in ls.
# # DISABLE_LS_COLORS="true"

# # Uncomment the following line to disable auto-setting terminal title.
# # DISABLE_AUTO_TITLE="true"

# # Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# # Uncomment the following line to display red dots whilst waiting for completion.
# # You can also set it to another string to have that shown instead of the default red dots.
# # e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# # Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# # Uncomment the following line if you want to disable marking untracked files
# # under VCS as dirty. This makes repository status check for large repositories
# # much, much faster.
# # DISABLE_UNTRACKED_FILES_DIRTY="true"

# # Uncomment the following line if you want to change the command execution time
# # stamp shown in the history command output.
# # You can set one of the optional three formats:
# # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# # or set a custom format using the strftime function format specifications,
# # see 'man strftime' for details.
# # HIST_STAMPS="mm/dd/yyyy"

# # Would you like to use another custom folder than $ZSH/custom?
# # ZSH_CUSTOM=/path/to/new-custom-folder

# export ZOXIDE_CMD_OVERRIDE=cd
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'


# # Which plugins would you like to load?
# # Standard plugins can be found in $ZSH/plugins/
# # Custom plugins may be added to $ZSH_CUSTOM/plugins/
# # Example format: plugins=(rails git textmate ruby lighthouse)
# # Add wisely, as too many plugins slow down shell startup.
# plugins=(
# 	asdf
# 	bgnotify
# 	git
# 	git-lfs
# 	git-auto-fetch
# 	gnu-utils
# 	zsh-autosuggestions
# 	zsh-interactive-cd
# 	fzf
# 	sudo
# 	thefuck
# 	command-not-found
# 	aliases
# 	alias-finder
# 	chucknorris
# 	colored-man-pages
# 	colorize
# 	docker
# 	eza
# 	jira
# 	jsontools
# 	pep8
# 	pip
# 	python
# 	safe-paste
# 	ssh
# 	systemd
# 	tldr
# 	tmuxinator
# 	ubuntu
# 	vscode
# 	zoxide
# 	you-should-use
# 	zsh-syntax-highlighting
# )

# source $ZSH/oh-my-zsh.sh

# # User configuration

# bindkey '^w' autosuggest-execute
# bindkey '^e' autosuggest-accept
# bindkey '^u' autosuggest-toggle
# bindkey '^L' vi-forward-word
# bindkey '^k' up-line-or-search
# bindkey '^j' down-line-or-search
# bindkey '^a' beginning-of-line
# bindkey '^e' end-of-line


# # navigation
# cx() { cd "$@" && l; }
# fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
# f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
# fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# # export MANPATH="/usr/local/man:$MANPATH"

# # You may need to manually set your language environment
# export LANG=en_US.UTF-8

# # Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='nvim'
# else
#   export EDITOR='code'
# fi

# # Compilation flags
# # export ARCHFLAGS="-arch $(uname -m)"

# # Set personal aliases, overriding those provided by Oh My Zsh libs,
# # plugins, and themes. Aliases can be placed here, though Oh My Zsh
# # users are encouraged to define aliases within a top-level file in
# # the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# # - $ZSH_CUSTOM/aliases.zsh
# # - $ZSH_CUSTOM/macos.zsh
# # For a full list of active aliases, run `alias`.
# #
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# # Lines configured by zsh-newuser-install
# HISTFILE=~/.histfile
# HISTSIZE=5000
# SAVEHIST=5000
# HISTDUP=erase
# setopt appendhistory sharehistory hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# setopt autocd beep extendedglob nomatch
# unsetopt notify
# # End of lines configured by zsh-newuser-install
# # The following lines were added by compinstall


# # End of lines added by compinstall

# # done by omz
# # eval "$(zoxide init --cmd cd zsh)"
# eval "$(atuin init zsh)"
# eval "$(navi widget zsh)"
# # eval "$(direnv hook zsh)"

# export PATH=/usr/games:$PATH


# source ~/f_fancy_box.zsh
# IFS=$'\n' wisdom=($(chuck_cow ))
# IFS=$'\n' greeting=($(toilet Welcome))
# IFS=$'\n' name=($(toilet Robert!))

# for ((i = 1; i <= ${#wisdom[@]}; i++)); do
# 	if (( ${#wisdom[i]} < 35 )); then

# 		wisdom[i]=$(printf "%-40s" "${wisdom[i]}")
# 	fi
# done
# # for ((i = 1; i <= ${#greeting[@]}; i++)); do
# # 	if (( ${#greeting[i]} < 100 )); then

# # 		greeting[i]=$(printf "%-100s" "${greeting[i]}")
# # 	fi
# # done
# # for ((i = 1; i <= ${#name[@]}; i++)); do
# # 	if (( ${#name[i]} < 100 )); then
# # 		name[i]=$(printf "%-100s" "${name[i]}")
# # 	fi
# # done

# text=(
# "000"
# " "
# $greeting
# $name
# " "
# "---"
# " "
# $wisdom
# " "
# "000"
# )

# f_fancy_box

# # chuck_cow
