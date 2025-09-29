{ config, pkgs, lib, ... }:
{
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
  ];

  programs.git = {
    enable = true;
    # Note: userName and userEmail should be set by the flake configuration
    # userName = "will be set by flake";
    # userEmail = "will be set by flake";
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
}