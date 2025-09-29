{ config, pkgs, lib, ... }:
{
  programs.bash = {
    enable = true;
    # shellAliases are configured in aliases.nix

    bashrcExtra = ''
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

      # PATH additions
      export PATH=$HOME/.claude/local:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin:$HOME/.npm-global/bin:./node_modules/.bin:$PATH

      # KUBECONFIG
      export KUBECONFIG=~/.kube/config

      # FZF configuration
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'

      # stdlib.sh disabled - was causing grep errors
      # if [ -f "$HOME/dotfiles/stdlib.sh/stdlib.sh" ]; then
      #   source "$HOME/dotfiles/stdlib.sh/stdlib.sh"
      # fi

      # Initialize carapace completion
      if command -v carapace >/dev/null 2>&1; then
        source <(carapace _carapace)
      fi

      # WSL-specific initialization
      if [ -z "''${CLAUDE:-}" ] && [ -f "$HOME/dotfiles/wsl-init.sh" ]; then
        source "$HOME/dotfiles/wsl-init.sh"
      fi

      # Source custom functions
      for func_file in "$HOME/dotfiles/scripts/functions"/*.sh; do
        if [ -f "$func_file" ]; then
          source "$func_file"
        fi
      done

      # History tool aliases (consistent with zsh)
      alias use-atuin='switch_history atuin'
      alias use-mcfly='switch_history mcfly'
      alias history-status='switch_history status'
      set +u
    '';
  };
}