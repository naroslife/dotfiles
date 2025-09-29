{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # shellAliases are configured in aliases.nix

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Source Nix
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix-daemon.sh" ]; then
          source "$HOME/.nix-profile/etc/profile.d/nix-daemon.sh"
        elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          source "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi

        # Load Home Manager session variables (needed for non-login interactive shells)
        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi

        unset PKG_CONFIG_LIBDIR
      '')
      ''
        # Key bindings
        bindkey '^w' autosuggest-execute
        bindkey '^e' autosuggest-accept
        bindkey '^u' autosuggest-toggle
        bindkey '^L' vi-forward-word
        bindkey '^k' up-line-or-search
        bindkey '^j' down-line-or-search
        bindkey '^W' backward-kill-word
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        # PATH additions
        export PATH=$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin:$HOME/.npm-global/bin:./node_modules/.bin:$PATH

        # KUBECONFIG
        export KUBECONFIG=~/.kube/config

        # FZF configuration
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'

        # Initialize carapace completion for zsh
        if command -v carapace >/dev/null 2>&1; then
          source <(carapace _carapace zsh)
        fi

        # WSL-specific initialization
        if [ -z "''${CLAUDE:-}" ] && [ -f "$HOME/dotfiles/wsl-init.sh" ]; then
          source "$HOME/dotfiles/wsl-init.sh"
        fi

        # Source custom functions (skip bash-specific files)
        for func_file in "$HOME/dotfiles/scripts/functions"/*.sh; do
          if [[ -f "$func_file" && "$func_file" != *"history-tools.sh" ]]; then
            source "$func_file"
          fi
        done

        # Source zsh-specific history tools
        if [ -f "$HOME/dotfiles/scripts/functions/history-tools-zsh.sh" ]; then
          source "$HOME/dotfiles/scripts/functions/history-tools-zsh.sh"
        fi

        # Override cd function for zsh (similar to bash but with zsh syntax)
        function cd() {
          show_reminder "cd" "br" "interactive directory navigation with broot"
          if [ -z "''${CLAUDE:-}" ]; then
            if command -v __zoxide_z >/dev/null 2>&1; then
              __zoxide_z "$@"
            else
              builtin cd "$@"
            fi
          else
            builtin cd "$@"
          fi
        }

        set +u
      ''
    ];
  };
}
