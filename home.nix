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

  # Session variables and paths are now managed in modules/environment.nix

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

    # SSH configuration is now managed in modules/dev/ssh.nix

    # Tool versions for asdf
    ".tool-versions".source = ./.tool-versions;

    # Git and VS Code configurations are managed in:
    # - modules/dev/git.nix
    # - modules/dev/vscode.nix
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