# Dotfiles

Personal dotfiles managed with [Home Manager](https://github.com/nix-community/home-manager) for reproducible development environments.

## Setup

1. Install Nix with flakes support:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone this repository with submodules:
   ```bash
   git clone --recursive https://github.com/naroslife/dotfiles.git ~/.config/dotfiles
   cd ~/.config/dotfiles
   ```

3. Apply the configuration:
   ```bash
   ./apply.sh
   ```
   
   Or manually:
   ```bash
   nix run home-manager/master -- switch --flake .#naroslife
   ```

## Structure

- `home.nix` - Main Home Manager configuration
- `flake.nix` - Nix flake definition
- `elvish/` - Elvish shell configuration  
- `nvim/` - Neovim configuration
- `tmux/` - Tmux configuration
- `starship/` - Starship prompt configuration
- `atuin/` - Atuin shell history configuration
- `ssh/` - SSH configuration
- `tmuxinator/` - Tmuxinator session configurations
- `termscp/` - Termscp file transfer tool configuration
- `carapace/` - Carapace completion framework specs
- `zshrc/` - Legacy Zsh configuration (integrated into home.nix)
- `base/` - Base shell framework (git submodule)
- `stdlib.sh/` - Bash standard library (git submodule)
- `util-linux/` - Custom util-linux build (git submodule)
- `.tool-versions` - Version specifications for development tools

## Tools Included

- **Shells**: Elvish (primary), Zsh (secondary), Bash (fallback)
- **Editor**: Neovim
- **Terminal Multiplexer**: Tmux with Tmuxinator
- **Prompt**: Starship
- **History**: Atuin
- **Fuzzy Finder**: fzf
- **File Navigator**: zoxide, ranger
- **Completion**: Carapace framework
- **Development**: Git, JDK 17, Maven, Gradle, Go, Node.js, Python 3.12, Ruby 3.3, Rust
- **Container Tools**: kubectl, kubectx, kubens
- **System Tools**: ripgrep, lazygit, lazydocker, bat, tree, eza, fd, and more

## Features

- **Version Management**: Tool versions specified in `.tool-versions`
- **Shell Integration**: Consistent aliases and functions across shells
- **Completion Framework**: Carapace for advanced completions
- **Custom Libraries**: Integration with base shell framework and stdlib.sh
- **File Transfer**: Termscp for secure file operations
- **Session Management**: Tmuxinator for complex tmux sessions

## Updating

To update your configuration:

```bash
cd ~/.config/dotfiles
git pull
git submodule update --remote
./apply.sh
```
