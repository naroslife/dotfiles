{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # === WSL Specific ===
    wslu # Windows Subsystem for Linux utilities (wslview, wslpath, etc.)
    # vcxsrv       # X server for Windows (enables GUI apps in WSL)

    # APT network switching scripts for WSL with Continental repos
    (writeShellScriptBin "apt-network-switch" (builtins.readFile ../scripts/apt-network-switch.sh))
  ];

  # WSL-specific environment variables and optimizations
  home.sessionVariables = {
    # WSL-specific optimizations
    WSLENV = "PATH/l:XDG_CONFIG_HOME/up";
    # Improve performance by using Windows TEMP for temporary files
    TMPDIR = "/tmp";
    PATH = "$HOME/.local/bin:/usr/local/cuda/bin:$PATH";

    # NVIDIA CUDA configuration for WSL2
    CUDA_HOME = "/usr/local/cuda";
    CUDA_PATH = "/usr/local/cuda";

    # Add custom library paths (keeps existing LD_LIBRARY_PATH if set)
    # Includes WSL NVIDIA libraries and CUDA paths
    LD_LIBRARY_PATH = "/usr/lib/wsl/lib:/usr/local/cuda/lib64:${config.home.homeDirectory}/inshipia/telekom/aaa/vowifi/migration/local/freediameter/lib:${config.home.homeDirectory}/inshipia/telekom/aaa/vowifi/migration/local/freeradius/lib:$LD_LIBRARY_PATH";
  };

  # WSL-specific aliases
  programs.bash.shellAliases = {
    # Clipboard integration aliases for WSL
    pbcopy = "clip.exe";
    pbpaste = "powershell.exe Get-Clipboard";

    # Windows app shortcuts
    code = "code.exe";
    explorer = "explorer.exe";
  };

  programs.zsh.shellAliases = {
    # Clipboard integration aliases for WSL
    pbcopy = "clip.exe";
    pbpaste = "powershell.exe Get-Clipboard";

    # Windows app shortcuts
    code = "code.exe";
    explorer = "explorer.exe";
  };

  # Additional WSL configuration files
  home.file = {
    # WSL init script (referenced by shells)
    ".config/wsl-init.sh".source = ../wsl-init.sh;
  };
}
