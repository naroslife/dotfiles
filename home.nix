{ config, pkgs, ... }:

let
  # Helper to check if running on WSL
  isWSL = pkgs.stdenv.isLinux && (pkgs.lib.strings.optionalString (pkgs.stdenv.hostPlatform.uname.kernel.release != null) pkgs.stdenv.hostPlatform.uname.kernel.release != "") =~ ".*-microsoft-.*";
in
{
  # Set home-manager state version
  home.stateVersion = "23.11"; # Adjust to your home-manager version

  # --- Packages to Install (Mapped from config.sh) ---
  home.packages = with pkgs; [
    # Essentials & Build Tools (from APT)
    git git-lfs curl wget stow jq fzf most tree bat # Added bat
    build-essential # Meta-package for gcc, make, etc.
    gnupg # For GPG keys
    # software-properties-common, ca-certificates, apt-transport-https, lsb-release are usually handled by NixOS/Nix environment

    # Shells & Terminal Tools (from APT)
    tmux
    elvish # Primary Shell
    bashInteractive # Secondary Shell (provides bash with readline support etc.)
    ripgrep
    lazygit
    lazydocker
    xclip
    tealdeer
    shellcheck

    # Dev Tools (from APT)
    # python3 provided below
    # ruby provided below
    # gem included with ruby
    jdk # OpenJDK (default version)
    maven gradle

    # C/C++ (from APT)
    gcc # Or clang if preferred
    gdb cmake ninja clang-tools lldb cppcheck valgrind boost

    # Documentation & Utils (from APT)
    doxygen graphviz

    # Python (from APT & PIP)
    python3 # Includes pip
    (python3.withPackages (ps: with ps; [
      # Add pip packages here
      thefuck
      pycodestyle # pep8 is now pycodestyle
      # Add other pip packages from your config or needs
    ]))

    # Ruby (from APT & GEM)
    (ruby.withPackages (rbps: with rbps; [
      # Add gem packages here
      tmuxinator
      # Add other gem packages from your config or needs
    ]))

    # Go (from GO_PACKAGES - ASDF handled separately)
    go
    # ASDF is installed via Go in config.sh, but Nix manages toolchains differently.
    # We install languages directly (go, nodejs, python3, jdk, rustup).
    # If you specifically need the ASDF *binary*, you can add it:
    # asdf-vm # Check exact package name if needed

    # Rust (from CARGO_PACKAGES)
    rustup # Installs rustup, run `rustup default stable` etc. manually first time
    eza
    # navi provided below
    # tldr # Consider pkgs.tldr or other clients like pkgs.tealdeer

    # Node.js (from NPM_PACKAGES)
    nodejs # Includes npm
    # Add global npm packages here if needed, e.g.:
    # yarn
    # typescript

    # Direct Downloads / Custom Installs (Alternatives)
    # elvish provided above
    navi   # Nix package for navi

    # Other tools potentially installed by setup.sh
    zoxide   # Already enabled via programs.zoxide
    starship # Already enabled via programs.starship
    atuin    # Already enabled via programs.atuin

    # WSL Utilities (Optional)
    # wslu # If running on WSL for wslview, etc.
  ];

  # --- Shell Configuration ---
    programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Integrates direnv with Nix shells
  };

  # --- Elvish (Primary) ---
  programs.elvish = {
    enable = true;
    # Add other elvish specific settings if needed
  };

  # --- Bash (Secondary) ---
  programs.bash = {
    enable = true;
    # Ensure bash integrations are enabled if you use them in bash
    # initExtra = ''
    #   eval "$(zoxide init bash)"
    #   eval "$(atuin init bash)"
    #   eval "$(starship init bash)"
    # '';
  };

  # --- Tool Integrations ---

  # Enable starship prompt (adjust integrations)
  programs.starship = {
    enable = true;
    enableBashIntegration = true;   # Secondary
    # enableZshIntegration = false; # Remove Zsh
  };

  # Enable zoxide (adjust integrations)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;   # Secondary
    # enableZshIntegration = false; # Remove Zsh
  };

  # Enable atuin (adjust integrations)
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;   # Secondary
    # enableZshIntegration = false; # Remove Zsh
    # Optional: Configure settings
    # settings = { ... };
  };

  # Enable fzf integration (adjust integrations)
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;   # Secondary
    # enableZshIntegration = false; # Remove Zsh
  };


  # --- Dotfile Management (Assuming Stow Layout) ---
  # Link files directly in the root of the dotfiles repo
  home.file.".bashrc".source = ./.bashrc;
  home.file.".profile".source = ./.profile;
  home.file.".gitconfig".source = ./.gitconfig;
  # home.file.".zshrc".source = ./.zshrc; # Remove Zsh config link

  # Link Elvish config directory/file
  home.file.".config/elvish/rc.elv" = {
     source = ./elvish/rc.elv; # Adjust source path if needed
     recursive = true; # Creates parent dirs (.config/elvish)
  };

  # Link directories using recursive = true
  # Assumes these directories exist in your dotfiles repo root
  home.file.".config/nvim" = { source = ./nvim; recursive = true; };
  home.file.".config/tmux" = { source = ./tmux; recursive = true; };
  home.file.".config/starship.toml" = { source = ./starship/starship.toml; recursive = true; }; # Link specific file, ensure parent dir exists
  home.file.".config/atuin" = { source = ./atuin; recursive = true; }; # If you have custom atuin config
  home.file.".config/bat" = { source = ./bat; recursive = true; }; # If you have custom bat config
  home.file.".local/share/navi" = { source = ./navi; recursive = true; }; # If you have custom navi cheatsheets

  # Add other directories/files managed by stow here...
  # Example: home.file.".config/alacritty" = { source = ./alacritty; recursive = true; };
  # Example: home.file.".ssh/config".source = ./.ssh/config; # Be careful with sensitive files

  # --- Environment Variables ---
  home.sessionVariables = {
    EDITOR = "nvim"; # Or your preferred editor
    PAGER = "most";
    SHELL = "${pkgs.elvish}/bin/elvish"; # Set default SHELL variable
    # Add other environment variables
  };

  # Allow home-manager to manage itself
  programs.home-manager.enable = true;
}