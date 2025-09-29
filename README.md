# Dotfiles

Modular dotfiles managed with [Home Manager](https://github.com/nix-community/home-manager) and [Nix Flakes](https://nixos.wiki/wiki/Flakes) for reproducible development environments.

## Features

- 🚀 **Modular Architecture** - Clean separation of concerns with focused modules
- 🔧 **Modern CLI Tools** - Replaces traditional tools with faster, more intuitive alternatives
- 🐚 **Multi-Shell Support** - Elvish (primary), Zsh, and Bash with shared configurations
- 💻 **Development Ready** - Complete toolchains for multiple languages and frameworks
- 🪟 **WSL Optimized** - Automatic detection and optimization for Windows Subsystem for Linux
- 📦 **Reproducible** - Nix ensures identical environments across machines

## Quick Start

### Prerequisites

- Linux or WSL2
- Git
- Internet connection

### Installation

```bash
# Clone the repository
git clone https://github.com/naroslife/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the setup script (installs Nix if needed)
./apply.sh
```

The setup script will:
1. Install Nix with flakes support (if not already installed)
2. Initialize git submodules
3. Detect your username and apply the appropriate configuration
4. Set up all shells, tools, and configurations

### Manual Installation

If you prefer manual control:

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Enable flakes
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Apply configuration
nix run home-manager/master -- switch --impure --flake .#$USER
```

## Project Structure

```
dotfiles/
├── flake.nix           # Nix flake definition with user configurations
├── home.nix           # Main home-manager entry point (minimal)
├── apply.sh           # Interactive setup script
│
├── modules/           # Modular Nix configurations
│   ├── default.nix   # Module aggregator
│   ├── core.nix      # Essential packages and utilities
│   ├── shells/       # Shell configurations
│   │   ├── bash.nix
│   │   ├── zsh.nix
│   │   └── elvish.nix
│   ├── dev/          # Development tools
│   │   ├── git.nix
│   │   ├── languages.nix
│   │   └── containers.nix
│   ├── cli/          # CLI tools
│   │   ├── modern.nix      # Modern replacements
│   │   └── productivity.nix
│   └── wsl.nix       # WSL-specific configuration
│
├── scripts/          # Shell scripts and functions
│   ├── apt-network-switch.sh  # WSL network detection
│   └── functions/   # Shell function libraries
│
├── config/          # Static configurations
│   ├── starship/    # Starship prompt
│   ├── atuin/       # Shell history
│   └── tmux/        # Terminal multiplexer
│
└── elvish/          # Elvish shell configuration
    ├── rc.elv
    └── lib/

```

## Included Tools

### Shell Environment

- **Primary Shell**: [Elvish](https://elv.sh/) - Friendly interactive shell with structured data
- **Secondary Shells**: Zsh with syntax highlighting, Bash with smart completions
- **Prompt**: [Starship](https://starship.rs/) - Fast, customizable, minimal prompt
- **History**: [Atuin](https://github.com/ellie/atuin) - Sync, search, and backup shell history
- **Completions**: [Carapace](https://github.com/rsteube/carapace) - Multi-shell completion framework

### Modern CLI Replacements

| Traditional | Modern Alternative | Description |
|------------|-------------------|-------------|
| `ls` | [eza](https://github.com/eza-community/eza) | Better listing with git integration |
| `cat` | [bat](https://github.com/sharkdp/bat) | Syntax highlighting and git integration |
| `find` | [fd](https://github.com/sharkdp/fd) | User-friendly and fast file finder |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | Blazingly fast recursive search |
| `sed` | [sd](https://github.com/chmln/sd) | Intuitive find and replace |
| `du` | [dust](https://github.com/bootandy/dust) | Intuitive disk usage visualizer |
| `df` | [duf](https://github.com/muesli/duf) | Better disk usage display |
| `ps` | [procs](https://github.com/dalance/procs) | Modern process viewer |
| `top` | [bottom](https://github.com/ClementTsang/bottom) | Graphical process monitor |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd that learns your habits |

### Development Tools

#### Version Control
- Git with [delta](https://github.com/dandavison/delta) diff viewer
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git
- [gh](https://cli.github.com/) - GitHub CLI

#### Languages & Frameworks
- **Java**: JDK 17, Maven, Gradle
- **C/C++**: GCC, CMake, Ninja, Meson
- **Python**: Python 3.12 with pip
- **Ruby**: Ruby 3.3 with bundler
- **Go**: Latest Go compiler
- **Rust**: Cargo and rustc
- **Node.js**: Node 20 with npm, yarn, pnpm

#### Container & Cloud
- Docker & docker-compose
- [lazydocker](https://github.com/jesseduffield/lazydocker) - Docker terminal UI
- kubectl & [k9s](https://k9scli.io/) - Kubernetes management
- Helm - Kubernetes package manager

### Text Editors
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based editor
- [Helix](https://helix-editor.com/) - Post-modern modal editor

### Productivity Tools
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [ranger](https://github.com/ranger/ranger) - Terminal file manager
- [broot](https://dystroy.org/broot/) - Interactive tree explorer
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [jq](https://stedolan.github.io/jq/) - JSON processor
- [yq](https://github.com/mikefarah/yq) - YAML processor

## Configuration

### User Management

Users are defined in `flake.nix`:

```nix
users = {
  username = {
    email = "user@example.com";
    fullName = "Full Name";
  };
};
```

### Adding New Modules

Create a new module in `modules/` and import it in `modules/default.nix`:

```nix
# modules/my-module.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # your packages
  ];
}
```

### WSL Integration

The configuration automatically detects WSL and:
- Configures clipboard integration (pbcopy/pbpaste)
- Sets up APT repository switching for corporate networks
- Optimizes performance settings
- Provides Windows interop commands

## Maintenance

### Update Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Apply Changes

After modifying configuration files:

```bash
./apply.sh
# or
home-manager switch --flake .#$USER
```

### Clean Old Generations

```bash
# List generations
home-manager generations

# Remove old generations
home-manager expire-generations "-30 days"
```

## Troubleshooting

### Common Issues

1. **Nix command not found**
   - Restart your shell or source the Nix profile:
   ```bash
   . ~/.nix-profile/etc/profile.d/nix.sh
   ```

2. **Flake evaluation errors**
   - Check syntax: `nix flake check`
   - Ensure all imports exist and are valid

3. **WSL-specific issues**
   - Run `./scripts/apt-network-switch.sh` to fix APT repositories
   - Ensure WSL2 is being used (not WSL1)

4. **Permission denied**
   - Home Manager doesn't require sudo
   - Ensure you own your home directory

## Contributing

Feel free to fork and customize for your own use! Key principles:
- Keep modules focused and under 200 lines
- Extract complex scripts to `scripts/` directory
- Document any new modules or significant changes
- Test changes with `nix flake check` before committing

## License

MIT - See [LICENSE](LICENSE) file for details

## Acknowledgments

- [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) communities
- Authors of all the amazing CLI tools included
- [NUR](https://github.com/nix-community/NUR) - Nix User Repository