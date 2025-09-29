{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # === Core System Utilities ===
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    less
    which
    file
    tree
    man
    man-pages

    # === Compression & Archives ===
    gzip
    unzip
    zip
    tar
    xz
    p7zip

    # === Network Essentials ===
    curl
    wget
    openssh
    netcat
    rsync

    # === Text Editors (Minimal) ===
    vim
    nano

    # === System Monitoring ===
    htop
    lsof
    strace

    # === Essential Build Tools ===
    gnumake
    gcc
    pkg-config

    # === Terminal Multiplexer ===
    tmux

    # === Shell Essentials ===
    bashInteractive
    bash-completion

    # === Fonts ===
    fira-code
    fira-code-symbols
    nerdfonts

    # === Nix Tools ===
    nix-tree
    nix-diff
    nixpkgs-fmt
    nil  # Nix language server
  ];
}