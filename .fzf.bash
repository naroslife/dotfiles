# Setup fzf
# ---------
if [[ ! "$PATH" == */home/naroslife/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/naroslife/.fzf/bin"
fi

eval "$(fzf --bash)"
