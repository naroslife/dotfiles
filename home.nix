{ config
, pkgs
, lib
, nurPackages ? {}
, ...
}:

let
  user = "uif58593";
  homeDir = "/home/${user}";
  gitUserName =  "uif58593";
  gitUserEmail = "robert.4.nagy@aumovio.com";

  # user = if config ? username then config.username else "naroslife";
  #   # Add this line for debugging:
  # _ = builtins.trace "DEBUG: home.username = ${user}" null;  homeDir = if config ? homeDirectory then config.homeDirectory else "/home/naroslife";
  # gitUserName = if config ? gitUserName then config.gitUserName else "naroslife";
  # gitUserEmail = if config ? gitUserEmail then config.gitUserEmail else "robi54321@gmail.com";
in
{
  home.stateVersion = "25.05";
  home.username = user;
  home.homeDirectory = homeDir;

  # Packages
  home.packages = with pkgs; [
    # === Version Control & Git Tools ===
    git
    git-lfs
    lazygit      # Terminal UI for git commands
    delta        # Syntax-highlighting pager for git diffs
    difftastic   # Structural diff that understands syntax trees
    gitui        # Blazing fast terminal-ui for git
    gh           # GitHub CLI for managing PRs, issues, etc.
    git-absorb   # Automatically absorb staged changes into your recent commits

    # === Shell & Terminal Environment ===
    bashInteractive
    zsh
    elvish       # Friendly interactive shell with structured data pipelines
    starship     # Fast, customizable prompt for any shell
    bash-completion
    zsh-completions
    carapace     # Multi-shell completion engine that works across bash, zsh, fish, etc.
    tmux
    direnv       # Load/unload environment variables based on directory

    # === Text Editors ===
    helix        # Modern modal editor with built-in LSP support

    # === Modern CLI Replacements ===
    bat          # cat with syntax highlighting and Git integration
    eza          # Modern ls replacement with colors and git status
    fd           # User-friendly find alternative
    ripgrep      # Fast grep replacement written in Rust
    zoxide       # Smarter cd command that learns your habits
    duf          # Disk usage/free utility with better UI than df
    dust         # Intuitive du replacement showing disk usage tree
    procs        # Modern ps replacement with tree view and search
    bottom       # Graphical process/system monitor (like htop but more features)
    htop-vim     # htop with vim keybindings
    lsof         # List open files and network connections
    sampler      # Terminal-based visual dashboard for monitoring systems
    pv           # Monitor progress of data through pipes

    # === File Management & Navigation ===
    tree
    ranger       # Console file manager with vi-like keybindings
    broot        # Interactive tree view, file manager, and launcher
    stow         # Symlink farm manager for dotfiles
    termscp      # Terminal file transfer client (SCP/SFTP/FTP/S3)
    rclone       # Sync files with cloud storage providers (S3, Drive, Dropbox, etc.)
    restic       # Fast, secure, and efficient backup program
    qdirstat   # Fast directory statistics and disk usage analyzer

    # === Text/Data Processing ===
    jq           # JSON processor
    yq-go        # YAML/JSON/XML/CSV processor (like jq for YAML)
    fx           # Interactive JSON viewer with mouse support
    miller       # Like awk/sed/cut/join for CSV, TSV, and JSON
    choose       # Human-friendly alternative to cut/awk for selecting fields
    most         # Pager like less but with multiple windows
    sad          # CLI search and replace with diff preview (Space Age sed)
    visidata     # Terminal spreadsheet for exploring and arranging tabular data

    # === Network Tools ===
    curl
    wget
    xh           # User-friendly HTTP client (like HTTPie but faster)
    httpie       # User-friendly HTTP client with intuitive syntax
    nmap         # Network discovery and security scanning
    rustscan     # Fast port scanner that pipes to nmap
    bandwhich    # Terminal bandwidth utilization monitor
    gping        # Ping with graph visualization
    dog          # DNS client like dig but with colorful output
    netcat       # TCP/IP swiss army knife
    wireshark    # Network protocol analyzer
    insomnia     # REST and GraphQL API client with GUI

    # === Container & Cloud Tools ===
    docker-compose
    lazydocker   # Terminal UI for docker and docker-compose
    kubectl      # Kubernetes CLI
    kubectx      # Quickly switch between kubectl contexts
    k9s          # Terminal UI for Kubernetes clusters
    helm         # Kubernetes package manager

    # === Database Tools ===
    pgcli        # PostgreSQL CLI with auto-completion and syntax highlighting
    usql         # Universal CLI for SQL databases (PostgreSQL, MySQL, SQLite, etc.)

    # === Development - Java ===
    jdk17
    maven
    gradle

    # === Development - C/C++ ===
    # Compilers & Build Systems
    gcc
    # clang
    cmake
    ninja        # Small build system focused on speed
    meson        # Fast and user-friendly build system
    bazel        # Google's build system for large-scale projects
    autoconf
    automake
    libtool
    pkg-config

    # C/C++ Libraries
    boost
    fmt          # Modern C++ formatting library
    spdlog       # Fast C++ logging library
    catch2       # Modern C++ test framework
    gtest        # Google Test framework
    eigen        # C++ template library for linear algebra
    opencv       # Computer vision library
    qt6.full
    gtk4
    glfw         # OpenGL/Vulkan window and input library
    glew         # OpenGL Extension Wrangler
    vulkan-headers
    vulkan-loader
    glibc.dev
    openssl
    ncurses.dev
    libcap.dev   # POSIX capabilities library
    systemd.dev

    # C/C++ Tools
    clang-tools  # clang-format, clang-tidy, etc.
    cppcheck     # Static analysis tool for C/C++
    valgrind     # Memory debugging and profiling
    gdb          # GNU debugger
    lldb         # LLVM debugger
    rr           # Record and replay debugger for C/C++ (time-travel debugging)
    sccache      # Shared compilation cache for C/C++/Rust (speeds up builds)
    strace       # Trace system calls and signals
    ltrace       # Trace library calls
    perf-tools   # Performance analysis tools

    # === Development - Other Languages ===
    go
    nodejs
    rustup       # Rust toolchain installer

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

    # === Learning & Productivity ===
    tealdeer     # Fast tldr pages implementation (command examples)
    cheat        # Create and view interactive cheatsheets
    navi         # Interactive cheatsheet tool with shell integration

    # === Security & Encryption ===
    gnupg        # GNU Privacy Guard
    pass         # Unix password manager using GPG

    # === Utilities ===
    xclip        # X11 clipboard interface
    wl-clipboard # Wayland clipboard utilities
    nix-prefetch-git  # Prefetch git repos for Nix expressions
    gettext      # Internationalization tools
    file         # Determine file types
    hexdump      # Display file contents in hex
    xxd          # Hex dump and reverse
    unzip
    p7zip        # 7-Zip file archiver

    # === WSL Specific ===
    wslu         # Windows Subsystem for Linux utilities (wslview, wslpath, etc.)
    # vcxsrv       # X server for Windows (enables GUI apps in WSL)

    # === Language-specific Package Managers ===
    # Python with common packages
    (python3.withPackages (ps: with ps; [
      pycodestyle  # Python style checker
      black        # Uncompromising Python formatter
      mypy         # Static type checker
      pytest       # Testing framework
      requests     # HTTP library
    ]))

    # Ruby with tmuxinator
    (ruby.withPackages (rbps: with rbps; [
      tmuxinator   # Manage tmux sessions easily
    ]))

    # === Shell History Tools (conditional) ===
    atuin        # Magical shell history using SQLite
    mcfly        # Intelligent command history search using neural networks

    # === Custom Scripts ===
    (writeShellScriptBin "claude-code" ''
      # Use npx to run the package (downloads/caches on first run)
      exec ${nodejs}/bin/npx -y @anthropic-ai/claude-code "$@"
    '')

    # APT network switching scripts for WSL with Continental repos
    (writeShellScriptBin "apt-network-switch" ''
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
          
          # Function to test corporate network connectivity - FAST VERSION
          test_corporate_network() {
              # Quick test: try to connect to first IP on port 443 (very fast)
              timeout 0.5 bash -c "echo >/dev/tcp/10.68.10.71/443" &>/dev/null && return 0
              
              # If that fails, try a quick ping to any corporate IP
              for ip in "''${CORP_TEST_IPS[@]}"; do
                  timeout 0.2 ping -c 1 -W 1 "$ip" &>/dev/null && return 0
              done
              
              return 1
          }
          
          # Parse command line arguments
          FORCE_MODE=""
          if [[ "$1" == "--force-corp" ]] || [[ "$1" == "-c" ]]; then
              FORCE_MODE="corp"
          elif [[ "$1" == "--force-public" ]] || [[ "$1" == "-p" ]]; then
              FORCE_MODE="public"
          elif [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
              echo "Usage: apt-network-switch [OPTIONS]"
              echo "  -c, --force-corp     Force corporate repositories"
              echo "  -p, --force-public   Force public repositories"
              echo "  -h, --help          Show this help message"
              exit 0
          fi
          
          if [[ -n "$FORCE_MODE" ]]; then
              echo -e "''${YELLOW}Forcing $FORCE_MODE mode...''${NC}"
              if [[ "$FORCE_MODE" == "corp" ]]; then
                  network_detected=0
              else
                  network_detected=1
              fi
          else
              echo -e "''${YELLOW}Quick network detection...''${NC}"
              test_corporate_network
              network_detected=$?
          fi
          
          if [[ $network_detected -eq 0 ]]; then
              echo -e "''${GREEN}✓ Corporate network detected (Continental/Automotive)''${NC}"
              
              # Enable corporate sources
              if [ -d "$DISABLED_DIR" ] && [ "$(ls -A $DISABLED_DIR 2>/dev/null)" ]; then
                  echo "Enabling corporate Artifactory repositories..."
                  sudo mv $DISABLED_DIR/*.list $SOURCES_DIR/ 2>/dev/null
              fi
              
              # Clear public sources
              if [ -s /etc/apt/sources.list ]; then
                  sudo cp /etc/apt/sources.list /etc/apt/sources.list.public-backup
                  echo "# Corporate network - using sources.list.d/*" | sudo tee /etc/apt/sources.list > /dev/null
              fi
              
              echo -e "''${GREEN}APT configured for corporate network''${NC}"
              
          else
              echo -e "''${YELLOW}✗ Home/Public network detected''${NC}"
              
              # Disable corporate sources
              sudo mkdir -p "$DISABLED_DIR"
              if [ "$(ls -A $SOURCES_DIR/*.list 2>/dev/null)" ]; then
                  echo "Disabling corporate repositories..."
                  sudo mv $SOURCES_DIR/*.list $DISABLED_DIR/ 2>/dev/null
              fi
              
              # Enable public Ubuntu sources
              if [ ! -s /etc/apt/sources.list ] || grep -q "using sources.list.d" /etc/apt/sources.list; then
                  echo "Enabling public Ubuntu repositories..."
                  cat << 'SOURCES' | sudo tee /etc/apt/sources.list > /dev/null
          # Ubuntu 22.04 (Jammy) repositories
          deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
          deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
          deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
          deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
          
          # Docker CE repository (public)
          # deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable
          SOURCES
              fi
              
              echo -e "''${GREEN}APT configured for public network''${NC}"
          fi
          
          echo -e "\n''${YELLOW}Running apt update...''${NC}"
          sudo apt update
          
          if [ $? -eq 0 ]; then
              echo -e "\n''${GREEN}✓ APT update successful!''${NC}"
          else
              echo -e "\n''${RED}✗ APT update failed. Check your network connection.''${NC}"
              exit 1
          fi
        '')
  ];

  # Shell configuration
  programs.bash = {
    enable = true;
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
      
      # Source base.sh if available
      # if [ -f "$HOME/dotfiles/base/base.sh" ]; then
      #   source "$HOME/dotfiles/base/base.sh"
      # fi
      
      # Source stdlib.sh if available  
      if [ -f "$HOME/dotfiles/stdlib.sh/stdlib.sh" ]; then
        source "$HOME/dotfiles/stdlib.sh/stdlib.sh"
      fi
      
      # Initialize carapace completion
      if command -v carapace >/dev/null 2>&1; then
        source <(carapace _carapace)
      fi
      
      # WSL-specific initialization
      if [ -z "''${CLAUDE:-}" ] && [ -f "$HOME/dotfiles/wsl-init.sh" ]; then
        source "$HOME/dotfiles/wsl-init.sh"
      fi
      
      # Custom functions
      cx() { cd "$@" && l; }
      fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
      f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | xclip -selection clipboard; }
      fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)"; }
      
      # Ranger function with cd integration
      function ranger {
        local IFS=$'\t\n'
        local tempfile="$(mktemp -t tmp.XXXXXX)"
        local ranger_cmd=(
          command
          rangerq
          --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
        )
        
        ''${ranger_cmd[@]} "$@"
        if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
          cd -- "$(cat "$tempfile")" || return
        fi
        command rm -f -- "$tempfile" 2>/dev/null
      }
      
      # Smart reminders for modern tools
      # Counter for tracking command usage
      if [[ ! -f ~/.command_counter ]]; then
        echo "cd=0" > ~/.command_counter
        echo "find=0" >> ~/.command_counter
        echo "htop=0" >> ~/.command_counter
        echo "top=0" >> ~/.command_counter
        echo "ls=0" >> ~/.command_counter
        echo "du=0" >> ~/.command_counter
        echo "df=0" >> ~/.command_counter
        echo "ps=0" >> ~/.command_counter
        echo "ping=0" >> ~/.command_counter
        echo "dig=0" >> ~/.command_counter
        echo "git_diff=0" >> ~/.command_counter
        echo "man=0" >> ~/.command_counter
        echo "wc=0" >> ~/.command_counter
      fi
      
      # Function to show reminder and increment counter
      show_reminder() {
        # Skip reminders if running under Claude (suppress noise)
        if [ -n "''${CLAUDE:-}" ]; then return 0; fi
        local cmd="$1"
        local alternative="$2" 
        local description="$3"
        local counter_file=~/.command_counter
        local current_count=$(grep "^$cmd=" "$counter_file" | cut -d= -f2 2>/dev/null || echo 0)
        
        # Show reminder every 5th usage
        if (( current_count % 5 == 4 )); then
          echo "💡 Reminder: Try '$alternative' instead of '$cmd' - $description"
        fi
        
        # Increment counter
        sed -i "s/^$cmd=.*/$cmd=$((current_count + 1))/" "$counter_file" 2>/dev/null || echo "$cmd=1" >> "$counter_file"
      }
      
      # Override cd to suggest broot occasionally
      cd() {
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
      
      # Override find to suggest fd
      find() {
        show_reminder "find" "fd" "faster and more user-friendly file finder"
        command find "$@"
      }
      
      # Override htop/top to suggest bottom
      htop() {
        show_reminder "htop" "btm" "modern system monitor with better visuals"
        command htop "$@"
      }
      
      top() {
        show_reminder "top" "btm" "modern system monitor with graphs and colors"
        command top "$@"
      }
      
      # Additional modern tool reminders
      ls() {
        show_reminder "ls" "eza" "modern ls with colors, icons, and git integration"
        command ls "$@"
      }
      
      du() {
        show_reminder "du" "dust" "modern du with tree view and colors"
        command du "$@"
      }
      
      df() {
        show_reminder "df" "duf" "modern df with better formatting and colors"
        command df "$@"
      }
      
      ps() {
        show_reminder "ps" "procs" "modern ps with colors and search capabilities"
        command ps "$@"
      }
      
      ping() {
        show_reminder "ping" "gping" "ping with real-time graphs"
        command ping "$@"
      }
      
      dig() {
        show_reminder "dig" "dog" "modern dig with better output and DNS-over-HTTPS"
        command dig "$@"
      }
      
      man() {
        show_reminder "man" "tldr" "simplified and practical examples"
        command man "$@"
      }
      
      wc() {
        show_reminder "wc" "tokei" "fast code line counter with language detection"
        command wc "$@"
      }
      
      # Git improvements (only show occasionally, not aliased)
      git() {
        if [[ "$1" == "diff" ]]; then
          show_reminder "git_diff" "git difftool" "use delta for syntax-highlighted diffs"
        fi
        command git "$@"
      }
      
      # Runtime history tool switcher (no rebuild needed)
      switch_history() {
        case "$1" in
          atuin)
            echo "🔄 Switching to Atuin (runtime)..."
            # Reset any existing history tools
            unset ATUIN_SESSION MCFLY_SESSION
            # Initialize Atuin
            if command -v atuin >/dev/null 2>&1; then
              eval "$(atuin init bash)"
              echo "✅ Atuin is now active! Try Ctrl+R"
            else
              echo "❌ Atuin not found. Make sure it's installed."
            fi
            ;;
          mcfly)
            echo "🔄 Switching to McFly (runtime)..."
            # Reset any existing history tools
            unset ATUIN_SESSION MCFLY_SESSION
            # Initialize McFly
            if command -v mcfly >/dev/null 2>&1; then
              export MCFLY_KEY_SCHEME=vim
              export MCFLY_FUZZY=2
              eval "$(mcfly init bash)"
              echo "✅ McFly is now active! Try Ctrl+R"
            else
              echo "❌ McFly not found. Make sure it's installed."
            fi
            ;;
          status)
            echo "📊 Current history tool status:"
            if [ -n "$ATUIN_SESSION" ]; then
              echo "  ✅ Atuin is active (session: ''${ATUIN_SESSION:0:8}...)"
            elif command -v mcfly >/dev/null 2>&1 && [ -n "$MCFLY_SESSION" ]; then
              echo "  ✅ McFly is active"
            else
              echo "  ❌ No history tool is currently active"
              echo "  💡 Available tools:"
              command -v atuin >/dev/null 2>&1 && echo "    - atuin"
              command -v mcfly >/dev/null 2>&1 && echo "    - mcfly"
            fi
            ;;
          *)
            echo "Usage: switch_history {atuin|mcfly|status}"
            echo "  atuin  - Switch to Atuin history search"
            echo "  mcfly  - Switch to McFly history search"  
            echo "  status - Show current active tool"
            ;;
        esac
      }
      
      # Sudo wrapper that preserves Nix environment
      # Usage: nsudo command [args...] - runs command with sudo while preserving Nix PATH
      nsudo() {
        if [ $# -eq 0 ]; then
          echo "Usage: nsudo <command> [args...]"
          echo "Runs command with sudo while preserving Nix tools in PATH"
          return 1
        fi
        sudo env PATH="$PATH" "$@"
      }
      
      # Alternative: sudo with preserved environment
      # Usage: sudo-nix command [args...] - same as nsudo but different name
      sudo-nix() {
        nsudo "$@"
      }
      
      # History tool aliases (consistent with zsh)
      alias use-atuin='switch_history atuin'
      alias use-mcfly='switch_history mcfly'
      alias history-status='switch_history status'
      set +u
    '';

    shellAliases = {
      # Home Manager
      hm = "nix run home-manager/master -- switch --flake . --impure";
      
      # Runtime history tool switching (consistent across shells)
      use-atuin = "switch_history atuin";
      use-mcfly = "switch_history mcfly";
      history-status = "switch_history status";
      
      # Sudo with Nix environment preservation
      nsudo = "sudo env PATH=$PATH";
      sudo-nix = "sudo env PATH=$PATH";
      
      # File operations
      la = "tree";
      cat = "bat";
      l = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      ltree = "eza --tree --level=2 --icons --git";

      # File operations with modern tools
      find = "fd";
      grep = "rg";
      ls = "eza";
      
      # Git aliases
      gc = "git commit -m";
      gca = "git commit -a -m";
      gp = "git push origin HEAD";
      gpu = "git pull origin";
      gst = "git status";
      glog = "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit";
      gdiff = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gba = "git branch -a";
      gadd = "git add";
      ga = "git add -p";
      gcoall = "git checkout -- .";
      gr = "git remote";
      gre = "git reset";
      
      # Docker
      dco = "docker compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      dl = "docker ps -l -q";
      dx = "docker exec -it";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
      
      # K8s
      k = "kubectl";
      ka = "kubectl apply -f";
      kg = "kubectl get";
      kd = "kubectl describe";
      kdel = "kubectl delete";
      kl = "kubectl logs -f";
      kgpo = "kubectl get pod";
      kgd = "kubectl get deployments";
      kc = "kubectx";
      ke = "kubectl exec -it";
      kcns = "kubectl config set-context --current --namespace";
      
      # Misc
      http = "xh";
      cl = "clear";
      v = "nvim";
      nm = "nmap -sC -sV -oN nmap";
      rr = "ranger";
      
      # Modern CLI replacements
      df = "duf";
      du = "dust";
      ps = "procs";
      top = "btm";
      htop = "btm";
      ping = "gping";
      dig = "dog";
      
      # Git improvements
      gd = "git diff";
      gdt = "git difftool";

      claude = "~/.claude/local/claude";

      # APT network management (Continental/WSL specific)
      apt-switch = "apt-network-switch";
      apt-update = "apt-network-switch";  # Override default with network-aware version
      apt-check = "apt-status";
      apt-public = "echo 'Forcing public repos...' && sudo mkdir -p /etc/apt/sources.list.d/disabled && sudo mv /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/disabled/ 2>/dev/null; echo 'deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse\ndeb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse' | sudo tee /etc/apt/sources.list > /dev/null && sudo apt update";
    
    };

  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      # Home Manager
      hm = "nix run home-manager/master -- switch --flake . --impure";
      
      # Runtime history tool switching (consistent across shells)
      use-atuin = "switch_history atuin";
      use-mcfly = "switch_history mcfly";
      history-status = "switch_history status";
      
      # Sudo with Nix environment preservation
      nsudo = "sudo env PATH=$PATH";
      sudo-nix = "sudo env PATH=$PATH";
      
      # File operations
      la = "tree";
      cat = "bat";
      l = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      ltree = "eza --tree --level=2 --icons --git";

      # File operations with modern tools
      find = "fd";
      grep = "rg";
      ls = "eza";
      
      # Git aliases
      gc = "git commit -m";
      gca = "git commit -a -m";
      gp = "git push origin HEAD";
      gpu = "git pull origin";
      gst = "git status";
      glog = "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit";
      gdiff = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gba = "git branch -a";
      gadd = "git add";
      ga = "git add -p";
      gcoall = "git checkout -- .";
      gr = "git remote";
      gre = "git reset";
      
      # Docker
      dco = "docker compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      dl = "docker ps -l -q";
      dx = "docker exec -it";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
      
      # K8s
      k = "kubectl";
      ka = "kubectl apply -f";
      kg = "kubectl get";
      kd = "kubectl describe";
      kdel = "kubectl delete";
      kl = "kubectl logs -f";
      kgpo = "kubectl get pod";
      kgd = "kubectl get deployments";
      kc = "kubectx";
      ke = "kubectl exec -it";
      kcns = "kubectl config set-context --current --namespace";
      
      # Misc
      http = "xh";
      cl = "clear";
      v = "nvim";
      nm = "nmap -sC -sV -oN nmap";
      rr = "ranger";
      
      # Modern CLI replacements
      df = "duf";
      du = "dust";
      ps = "procs";
      top = "btm";
      htop = "btm";
      ping = "gping";
      dig = "dog";
      
      # Git improvements
      gd = "git diff";
      gdt = "git difftool";

      # APT network management (Continental/WSL specific)
      apt-switch = "apt-network-switch";
      apt-update = "apt-network-switch";  # Override default with network-aware version
      apt-check = "apt-status";
      apt-public = "echo 'Forcing public repos...' && sudo mkdir -p /etc/apt/sources.list.d/disabled && sudo mv /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/disabled/ 2>/dev/null; echo 'deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse\ndeb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse' | sudo tee /etc/apt/sources.list > /dev/null && sudo apt update";
    
    };
    
    initContent = ''
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
      
      # VI mode
      # bindkey jj vi-cmd-mode
      
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
      
      # Source base.sh if available
      # if [ -f "$HOME/dotfiles/base/base.sh" ]; then
      #   source "$HOME/dotfiles/base/base.sh"
      # fi
      
      # Source stdlib.sh if available  
      # if [ -f "$HOME/dotfiles/stdlib.sh/stdlib.sh" ]; then
      #   source "$HOME/dotfiles/stdlib.sh/stdlib.sh"
      # fi
      
      # Initialize carapace completion for zsh
      if command -v carapace >/dev/null 2>&1; then
        source <(carapace _carapace zsh)
      fi
      
      # WSL-specific initialization
      if [ -z "''${CLAUDE:-}" ] && [ -f "$HOME/dotfiles/wsl-init.sh" ]; then
        source "$HOME/dotfiles/wsl-init.sh"
      fi
      
      # Custom functions
      cx() { cd "$@" && l; }
      fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
      f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | xclip -selection clipboard; }
      fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)"; }
      
      # Ranger function with cd integration
      function ranger {
        local IFS=$'\t\n'
        local tempfile="$(mktemp -t tmp.XXXXXX)"
        local ranger_cmd=(
          command
          ranger
          --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
        )
        
        ''${ranger_cmd[@]} "$@"
        if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
          cd -- "$(cat "$tempfile")" || return
        fi
        command rm -f -- "$tempfile" 2>/dev/null
      }
      
      # Smart reminders for modern tools
      # Counter for tracking command usage
      if [[ ! -f ~/.command_counter ]]; then
        echo "cd=0" > ~/.command_counter
        echo "find=0" >> ~/.command_counter
        echo "htop=0" >> ~/.command_counter
        echo "top=0" >> ~/.command_counter
        echo "ls=0" >> ~/.command_counter
        echo "du=0" >> ~/.command_counter
        echo "df=0" >> ~/.command_counter
        echo "ps=0" >> ~/.command_counter
        echo "ping=0" >> ~/.command_counter
        echo "dig=0" >> ~/.command_counter
        echo "git_diff=0" >> ~/.command_counter
        echo "man=0" >> ~/.command_counter
        echo "wc=0" >> ~/.command_counter
      fi
      
      # Function to show reminder and increment counter
      show_reminder() {
        # Skip reminders if running under Claude (suppress noise)
        if [ -n "''${CLAUDE:-}" ]; then return 0; fi
        local cmd="$1"
        local alternative="$2" 
        local description="$3"
        local counter_file=~/.command_counter
        local current_count=$(grep "^$cmd=" "$counter_file" | cut -d= -f2 2>/dev/null || echo 0)
        
        # Show reminder every 5th usage
        if (( current_count % 5 == 4 )); then
          echo "💡 Reminder: Try '$alternative' instead of '$cmd' - $description"
        fi
        
        # Increment counter
        sed -i "s/^$cmd=.*/$cmd=$((current_count + 1))/" "$counter_file" 2>/dev/null || echo "$cmd=1" >> "$counter_file"
      }
      
      # Override commands to suggest modern alternatives
      # Directory navigation
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
      
      # File operations
      function find() {
        show_reminder "find" "fd" "faster and more user-friendly file finder"
        command find "$@"
      }
      
      function ls() {
        show_reminder "ls" "eza" "modern ls with colors, icons, and git integration"
        command ls "$@"
      }
      
      # System monitoring
      function htop() {
        show_reminder "htop" "btm" "modern system monitor with better visuals"
        command htop "$@"
      }
      
      function top() {
        show_reminder "top" "btm" "modern system monitor with graphs and colors"
        command top "$@"
      }
      
      # Disk usage
      function du() {
        show_reminder "du" "dust" "modern du with tree view and colors"
        command du "$@"
      }
      
      function df() {
        show_reminder "df" "duf" "modern df with better formatting and colors"
        command df "$@"
      }
      
      # Process listing
      function ps() {
        show_reminder "ps" "procs" "modern ps with colors and search capabilities"
        command ps "$@"
      }
      
      # Network tools
      function ping() {
        show_reminder "ping" "gping" "ping with real-time graphs"
        command ping "$@"
      }
      
      function dig() {
        show_reminder "dig" "dog" "modern dig with better output and DNS-over-HTTPS"
        command dig "$@"
      }
      
      # Documentation and help
      function man() {
        show_reminder "man" "tldr" "simplified and practical examples"
        command man "$@"
      }
      
      # Code analysis
      function wc() {
        show_reminder "wc" "tokei" "fast code line counter with language detection"
        command wc "$@"
      }
      
      # Git improvements (only show occasionally, not aliased)
      function git() {
        if [[ "$1" == "diff" ]]; then
          show_reminder "git_diff" "git difftool" "use delta for syntax-highlighted diffs"
        fi
        command git "$@"
      }
      
      # Runtime history tool switcher (same as bash)
      switch_history() {
        case "$1" in
          atuin)
            echo "🔄 Switching to Atuin (runtime)..."
            # Reset any existing history tools
            unset ATUIN_SESSION MCFLY_SESSION
            # Initialize Atuin
            if command -v atuin >/dev/null 2>&1; then
              eval "$(atuin init zsh)"
              echo "✅ Atuin is now active! Try Ctrl+R"
            else
              echo "❌ Atuin not found. Make sure it's installed."
            fi
            ;;
          mcfly)
            echo "🔄 Switching to McFly (runtime)..."
            # Reset any existing history tools
            unset ATUIN_SESSION MCFLY_SESSION
            # Initialize McFly
            if command -v mcfly >/dev/null 2>&1; then
              export MCFLY_KEY_SCHEME=vim
              export MCFLY_FUZZY=2
              eval "$(mcfly init zsh)"
              echo "✅ McFly is now active! Try Ctrl+R"
            else
              echo "❌ McFly not found. Make sure it's installed."
            fi
            ;;
          status)
            echo "📊 Current history tool status:"
            if [ -n "$ATUIN_SESSION" ]; then
              echo "  ✅ Atuin is active (session: ''${ATUIN_SESSION:0:8}...)"
            elif command -v mcfly >/dev/null 2>&1 && [ -n "$MCFLY_SESSION" ]; then
              echo "  ✅ McFly is active"
            else
              echo "  ❌ No history tool is currently active"
              echo "  💡 Available tools:"
              command -v atuin >/dev/null 2>&1 && echo "    - atuin"
              command -v mcfly >/dev/null 2>&1 && echo "    - mcfly"
            fi
            ;;
          *)
            echo "Usage: switch_history {atuin|mcfly|status}"
            echo "  atuin  - Switch to Atuin history search"
            echo "  mcfly  - Switch to McFly history search"  
            echo "  status - Show current active tool"
            ;;
        esac
      }
      
      # Sudo wrapper that preserves Nix environment
      # Usage: nsudo command [args...] - runs command with sudo while preserving Nix PATH
      nsudo() {
        if [ $# -eq 0 ]; then
          echo "Usage: nsudo <command> [args...]"
          echo "Runs command with sudo while preserving Nix tools in PATH"
          return 1
        fi
        sudo env PATH="$PATH" "$@"
      }
      
      # Alternative: sudo with preserved environment
      # Usage: sudo-nix command [args...] - same as nsudo but different name
      sudo-nix() {
        nsudo "$@"
      }
      set +u
    '';
  };

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

  programs.git = {
    enable = true;
    userName = gitUserName;
    userEmail = gitUserEmail;
    extraConfig = {
      core = {
        editor = "code";
        autocrlf = "input";  # WSL: Handle line endings properly
        safecrlf = true;     # WSL: Warn about mixed line endings
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      merge.conflictstyle = "diff3";
      rerere.enabled = true;
      diff.colorMoved = "default";
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        features = "decorations";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow";
        };
        whitespace-error-style = "22 reverse";
      };
    };
  };

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

  # Configuration files
  home.file = {
    # Starship config
    ".config/starship/starship.toml".source = ./starship/starship.toml;
    
    # Atuin config
    ".config/atuin/config.toml".source = ./atuin/config.toml;
    
    # SSH config
    ".ssh/config".source = ./ssh/ssh-config;
        
    # Tmuxinator configs
    ".config/tmuxinator" = {
      source = ./tmuxinator;
      recursive = true;
    };
    
    # Termscp config
    ".config/termscp" = {
      source = ./termscp;
      recursive = true;
    };
    
    # Carapace completion specs
    ".config/carapace/specs" = {
      source = ./carapace/specs;
      recursive = true;
    };
    
    # Elvish config
    ".config/elvish" = {
      source = ./elvish;
      recursive = true;
    };
    
    # Neovim config
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
    
    # Tool versions (for asdf/rtx compatibility)
    ".tool-versions".source = ./.tool-versions;
    
    # Modern tool configs
    ".config/bottom/bottom.toml".text = ''
      [flags]
      dot_marker = false
      
      [colors]
      table_header_color = "LightBlue"
      all_cpu_color = "Red"
      avg_cpu_color = "Green"
      cpu_core_colors = ["LightMagenta", "LightYellow", "LightCyan", "LightGreen", "LightBlue", "LightRed", "Cyan", "Green", "Blue", "Red"]
    '';
    
    # NPM configuration
    ".npmrc".text = ''
      prefix=''${HOME}/.npm-global
    '';
    
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "code";
    # BROWSER = "firefox";
    # TERMINAL = "alacritty";
    KUBECONFIG = "$HOME/.kube/config";
    XDG_CONFIG_HOME = "$HOME/.config";
    FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow";
    # STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";

    # Prefer system pkg-config and ensure Ubuntu pc dirs are visible
    PKG_CONFIG = "/usr/bin/pkg-config";
    PKG_CONFIG_PATH = "/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig";
    
    # Modern CLI tool configurations
    BAT_THEME = "base16";
    DELTA_FEATURES = "+side-by-side";
    
    # NPM configuration for user-level global installs
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    
    # WSL-specific optimizations
    WSLENV = "PATH/l:XDG_CONFIG_HOME/up";
    # Improve performance by using Windows TEMP for temporary files
    TMPDIR = "/tmp";
    PATH = "$HOME/.local/bin:$PATH";

    # Add custom library paths (keeps existing LD_LIBRARY_PATH if set)
    LD_LIBRARY_PATH = "${config.home.homeDirectory}/inshipia/telekom/aaa/vowifi/migration/local/freediameter/lib:${config.home.homeDirectory}/inshipia/telekom/aaa/vowifi/migration/local/freeradius/lib:$LD_LIBRARY_PATH";
  };

  # Additional modern programs
  programs.broot = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  
  # programs.nushell = {
  #   enable = true;
  # };
  
  programs.mcfly = {
    enable = false;
    enableBashIntegration = false;
    enableZshIntegration = false;
    keyScheme = "vim";
    fuzzySearchFactor = 2;
  };
}
