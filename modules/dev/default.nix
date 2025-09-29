{ config, pkgs, lib, ... }:
{
  imports = [
    ./git.nix
    ./languages.nix
    ./containers.nix
  ];

  home.packages = with pkgs; [
    # === Text Editors ===
    helix        # Modern modal editor with built-in LSP support

    # === Documentation & Code Quality ===
    doxygen      # Documentation generator from source code
    graphviz     # Graph visualization software
    pandoc       # Universal document converter
    glow         # Render markdown files beautifully in the terminal
    obsidian     # Knowledge base and note-taking app with graph view
    shellcheck   # Shell script static analysis
    shfmt        # Shell script formatter
    tokei        # Count lines of code quickly
    hyperfine    # Command-line benchmarking tool
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      vim-tmux-navigator
    ];
    extraConfig = ''
      # Enable mouse support
      set -g mouse on

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Renumber windows when a window is closed
      set -g renumber-windows on

      # Use vim keybindings in copy mode
      setw -g mode-keys vi

      # Better split bindings
      bind | split-window -h
      bind - split-window -v
    '';
  };
}