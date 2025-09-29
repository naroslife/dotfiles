{ config, pkgs, lib, ... }:
{
  imports = [
    ./bash.nix
    ./zsh.nix
    ./elvish.nix
  ];

  home.packages = with pkgs; [
    # === Shell & Terminal Environment ===
    starship     # Fast, customizable prompt for any shell
    bash-completion
    zsh-completions
    carapace     # Multi-shell completion engine that works across bash, zsh, fish, etc.
    direnv       # Load/unload environment variables based on directory

    # === Shell History Tools ===
    atuin        # Magical shell history using SQLite
    mcfly        # Intelligent command history search using neural networks
  ];

  # Tool integrations
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = false;
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  programs.broot = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.mcfly = {
    enable = false;
    enableBashIntegration = false;
    enableZshIntegration = false;
    keyScheme = "vim";
    fuzzySearchFactor = 2;
  };
}