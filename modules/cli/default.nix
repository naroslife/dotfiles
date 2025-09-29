{ config, pkgs, lib, ... }:
{
  imports = [
    ./modern.nix
    ./productivity.nix
  ];

  home.packages = with pkgs; [
    # === Network Essentials ===
    curl
    wget

    # === Terminal Multiplexer ===
    tmux
  ];

  # Additional configurations shared across CLI tools
  home.file = {
    # Starship config
    ".config/starship/starship.toml".source = ../../starship/starship.toml;

    # Atuin config
    ".config/atuin/config.toml".source = ../../atuin/config.toml;

    # SSH config
    ".ssh/config".source = ../../ssh/ssh-config;

    # Tmuxinator configs
    ".config/tmuxinator" = {
      source = ../../tmuxinator;
      recursive = true;
    };

    # Elvish config
    ".config/elvish" = {
      source = ../../elvish;
      recursive = true;
    };

    # Neovim config
    ".config/nvim" = {
      source = ../../nvim;
      recursive = true;
    };
  };

  # WSL-specific optimizations
  home.sessionVariables = {
    WSLENV = "PATH/l:XDG_CONFIG_HOME/up";
    # Improve performance by using Windows TEMP for temporary files
    TMPDIR = "/tmp";
    PATH = "$HOME/.local/bin:$PATH";
  };
}