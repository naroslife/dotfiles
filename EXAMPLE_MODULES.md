# Example Module Structure

## Main home.nix (Simplified)
```nix
# home.nix - Now less than 50 lines!
{ config, pkgs, lib, ... }:
let
  username = config.home.username;
  homeDir = config.home.homeDirectory;
in
{
  imports = [ ./modules ];

  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = homeDir;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Basic session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
  };
}
```

## modules/default.nix
```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ./core.nix
    ./shells
    ./dev
    ./cli
  ] ++ lib.optional (builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop) ./wsl.nix;
}
```

## modules/core.nix
```nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    findutils
    gnugrep
    gnused
    gawk

    # Network tools
    curl
    wget
    openssh

    # Compression
    gzip
    unzip
    tar
    xz

    # Essential tools
    file
    which
    tree
    less
    man
  ];
}
```

## modules/shells/bash.nix
```nix
{ config, pkgs, lib, ... }:
let
  functionsDir = ../../scripts/functions;
in
{
  programs.bash = {
    enable = true;

    # Source external function files
    initExtra = ''
      # Source function libraries
      for func_file in ${functionsDir}/*.sh; do
        [ -f "$func_file" ] && source "$func_file"
      done

      # WSL-specific initialization
      ${lib.optionalString (builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop) ''
        source ${../../scripts/wsl-init.sh}
      ''}
    '';

    shellAliases = import ./aliases.nix;

    sessionVariables = {
      HISTCONTROL = "ignoreboth:erasedups";
      HISTSIZE = "10000";
      HISTFILESIZE = "20000";
    };
  };
}
```

## modules/shells/aliases.nix
```nix
{
  # Navigation
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";

  # Modern replacements
  ls = "eza";
  ll = "eza -l";
  la = "eza -la";
  tree = "eza --tree";

  cat = "bat";
  grep = "rg";
  find = "fd";

  # Git shortcuts
  g = "git";
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gp = "git push";
  gl = "git log --oneline";

  # Docker shortcuts
  d = "docker";
  dc = "docker compose";
  dps = "docker ps";

  # Kubernetes
  k = "kubectl";
  kgp = "kubectl get pods";
  kgs = "kubectl get services";
}
```

## modules/dev/git.nix
```nix
{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;

    userEmail = config.programs.git.userEmail or "user@example.com";
    userName = config.programs.git.userName or "User";

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";

      # Advanced aliases
      graph = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      contributors = "shortlog --summary --numbered";

      # Workflow aliases
      feature = "checkout -b";
      publish = "push -u origin HEAD";
      unpublish = "push origin --delete";
      sync = "!git fetch --all --prune && git rebase origin/main";
    };

    extraConfig = {
      core = {
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      };

      pull = {
        rebase = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
      };

      merge = {
        tool = "vimdiff";
      };

      diff = {
        colorMoved = "default";
      };
    };

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = true;
      };
    };

    lfs.enable = true;
  };
}
```

## modules/cli/modern.nix
```nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Modern CLI replacements
    bat           # cat replacement
    eza           # ls replacement
    fd            # find replacement
    ripgrep       # grep replacement
    sd            # sed replacement
    duf           # df replacement
    dust          # du replacement
    procs         # ps replacement
    bottom        # top replacement
    tealdeer      # tldr pages

    # JSON/YAML tools
    jq
    yq

    # File management
    ranger
    nnn

    # System monitoring
    btop
    glances

    # Network tools
    httpie
    curlie
    xh
    bandwhich

    # Productivity
    tokei         # Code statistics
    hyperfine     # Benchmarking
    just          # Command runner
  ];

  # Configure modern tools
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
  };

  programs.broot = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
```

## modules/wsl.nix
```nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # WSL utilities
    wslu

    # Windows interop script
    (pkgs.writeShellScriptBin "apt-network-switch"
      (builtins.readFile ../scripts/apt-network-switch.sh))
  ];

  # WSL-specific aliases
  programs.bash.shellAliases = {
    # Clipboard integration
    pbcopy = "clip.exe";
    pbpaste = "powershell.exe -command 'Get-Clipboard'";

    # Open in Windows
    open = "wslview";
    explorer = "explorer.exe";
  };

  # WSL environment variables
  home.sessionVariables = {
    BROWSER = "wslview";
    DISPLAY = ":0";
  };

  # WSL initialization
  programs.bash.initExtra = lib.mkAfter ''
    # WSL-specific initialization
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
      # Set proper umask
      umask 022

      # Fix WSL path issues
      export PATH="$PATH:/mnt/c/Windows/System32"

      # Daily APT network check (Continental-specific)
      APT_CHECK_FILE="$HOME/.apt-network-checked-$(date +%Y%m%d)"
      if [ ! -f "$APT_CHECK_FILE" ]; then
        ${config.home.homeDirectory}/.nix-profile/bin/apt-network-switch --quiet
        touch "$APT_CHECK_FILE"
        # Clean up old check files
        find "$HOME" -name ".apt-network-checked-*" -mtime +1 -delete 2>/dev/null
      fi
    fi
  '';
}
```

## scripts/apt-network-switch.sh
```bash
#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CORP_HOST="geo.artifactory.automotive.cloud"
CORP_TEST_IPS=("10.68.10.71" "10.68.8.19" "10.68.10.193")
SOURCES_DIR="/etc/apt/sources.list.d"
DISABLED_DIR="$SOURCES_DIR/disabled"

# Function to test corporate network connectivity
test_corporate_network() {
    # Quick test: try to connect to first IP on port 443
    timeout 0.5 bash -c "echo >/dev/tcp/10.68.10.71/443" &>/dev/null && return 0

    # If that fails, try a quick ping to any corporate IP
    for ip in "${CORP_TEST_IPS[@]}"; do
        timeout 0.2 ping -c 1 -W 1 "$ip" &>/dev/null && return 0
    done

    return 1
}

# ... rest of script content extracted from home.nix ...
```

## flake.nix (Simplified)
```nix
{
  description = "Modular Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ nur.overlays.default ];
      };

      mkHomeConfig = username: {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
            }
          ];
        };
      };
    in {
      homeConfigurations = mkHomeConfig "uif58593" // mkHomeConfig "naroslife";
    };
}
```

## Benefits of This Structure

1. **Modularity**: Each concern in its own file
2. **Reusability**: Modules can be imported selectively
3. **Maintainability**: Easy to find and update specific configs
4. **Scalability**: Add new modules without touching existing ones
5. **Clarity**: Clear separation of concerns
6. **Performance**: Faster evaluation of individual modules
7. **Testing**: Can test modules independently