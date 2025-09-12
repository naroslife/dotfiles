
{ config, pkgs, lib, ... }:

let
  user = builtins.getEnv "USER";
  homeDir = builtins.getEnv "HOME";
in
{
  home.stateVersion = "25.05";
  home.username = if user != "" then user else "naroslife";
  home.homeDirectory = if homeDir != "" then homeDir else "/home/naroslife";

  # Packages
  home.packages = with pkgs; [
    # Essential tools
    git git-lfs curl wget jq tree bat gnupg stow
    ripgrep lazygit lazydocker xclip tealdeer shellcheck
    fd fzf eza most zoxide direnv
    
    # History tools (conditionally installed based on programs config)
    atuin mcfly
    
    # WSL-specific utilities
    wslu        # WSL utilities (wslview, wslpath, wslvar)
    wl-clipboard # Wayland clipboard (backup for xclip)
    
    # Modern CLI replacements
    duf        # Modern df alternative
    dust       # Modern du alternative  
    procs      # Modern ps alternative
    bottom     # Modern top/htop alternative
    hyperfine  # Benchmarking tool
    tokei      # Count lines of code
    delta      # Better git diff
    
    # Network tools
    nmap xh bandwhich gping
    
    # Modern development tools
    jdk17 maven gradle
    # gcc gdb clang-tools lldb cppcheck valgrind boost glibc.dev
    doxygen graphviz
    go nodejs rustup navi
        
    # Modern Git tools
    gh         # GitHub CLI
    git-absorb # Better git commit --fixup
    gitui      # Terminal Git UI
    
    # Container and Cloud tools
    kubectl kubectx
    docker-compose
    helm
    k9s        # Kubernetes TUI
    
    # File and text processing
    yq-go      # YAML processor
    fx         # JSON viewer
    miller     # CSV/JSON processor
    choose     # Human-friendly cut
    
    # Shell environments
    elvish bashInteractive zsh starship
    
    # Terminal tools and file managers
    tmux ranger carapace termscp
    # nushell    # Modern shell
    
    # Completion tools
    bash-completion zsh-completions
    
    # Modern system monitoring
    lsof
    htop-vim   # Htop with vim keys
    
    # Security and networking
    rustscan   # Fast port scanner
    dog        # Modern dig
    
    # Productivity tools
    cheat      # Command cheatsheets
    broot      # Interactive directory navigator
    
    # Archive tools
    unzip p7zip

    (writeShellScriptBin "claude-code" ''
      # Use npx to run the package (downloads/caches on first run)
      exec ${nodejs}/bin/npx -y @anthropic-ai/claude-code "$@"
      # For a pinned version, use:
      # exec ${nodejs}/bin/npx -y @anthropic-ai/claude-code@<version> "$@"
    '')
    
    # Python with packages (version 3.12.5 as per .tool-versions)
    (python3.withPackages (ps: with ps; [
      pycodestyle
      black      # Code formatter
      mypy       # Type checker
      pytest     # Testing framework
      requests   # HTTP library
    ]))

    # Ruby with packages (version 3.3.4 as per .tool-versions)
    (ruby.withPackages (rbps: with rbps; [
      tmuxinator
    ]))
    
    # Util-linux build dependencies
    autoconf automake libtool gettext pkg-config
    ncurses.dev libcap.dev systemd.dev
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
    
    };
    
    initExtra = ''
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