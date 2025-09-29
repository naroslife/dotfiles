{ config, pkgs, lib, ... }:
let
  username = config.home.username or "user";
  homeDir = config.home.homeDirectory or "/home/${username}";
in
{
  # Import all modules
  imports = [ ./modules ];

  # Home Manager configuration
  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = homeDir;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Basic session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    TERMINAL = "alacritty";

    # Development
    GOPATH = "${homeDir}/go";
    CARGO_HOME = "${homeDir}/.cargo";
    RUSTUP_HOME = "${homeDir}/.rustup";

    # XDG Base Directory Specification
    XDG_CONFIG_HOME = "${homeDir}/.config";
    XDG_DATA_HOME = "${homeDir}/.local/share";
    XDG_STATE_HOME = "${homeDir}/.local/state";
    XDG_CACHE_HOME = "${homeDir}/.cache";

    # PATH additions
    PATH = lib.concatStringsSep ":" [
      "${homeDir}/bin"
      "${homeDir}/.local/bin"
      "${homeDir}/go/bin"
      "${homeDir}/.cargo/bin"
      "\${PATH}"
    ];
  };

  # Session path
  home.sessionPath = [
    "${homeDir}/bin"
    "${homeDir}/.local/bin"
    "${homeDir}/go/bin"
    "${homeDir}/.cargo/bin"
  ];

  # File management
  home.file = {
    # Elvish configuration
    ".config/elvish/rc.elv".source = ./elvish/rc.elv;
    ".config/elvish/lib".source = ./elvish/lib;
    ".config/elvish/aliases".source = ./elvish/aliases;

    # Tmux scripts (configuration now in modules/dev/default.nix)
    ".config/tmux/scripts".source = ./tmux/scripts;

    # Carapace configuration
    ".config/carapace".source = ./carapace;

    # Note: starship, tmux, and atuin configurations are now managed
    # via Nix modules in modules/shells/default.nix and modules/dev/default.nix

    # SSH configuration
    ".ssh/config" = {
      source = ./ssh/config;
      onChange = "chmod 600 ~/.ssh/config";
    };

    # Tool versions for asdf
    ".tool-versions".source = ./.tool-versions;
  };

  # XDG configuration
  xdg = {
    enable = true;
    configHome = "${homeDir}/.config";
    dataHome = "${homeDir}/.local/share";
    stateHome = "${homeDir}/.local/state";
    cacheHome = "${homeDir}/.cache";

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${homeDir}/Desktop";
      download = "${homeDir}/Downloads";
      documents = "${homeDir}/Documents";
      music = "${homeDir}/Music";
      pictures = "${homeDir}/Pictures";
      videos = "${homeDir}/Videos";
      publicShare = "${homeDir}/Public";
      templates = "${homeDir}/Templates";
    };
  };

  # News - notify about home-manager news
  news.display = "notify";
}