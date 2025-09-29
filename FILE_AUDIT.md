# File Audit for Dotfiles Repository

## Files to DELETE Immediately

### Large/Binary Files
- **FiraCode.zip** (27MB) - Use `pkgs.fira-code` in Nix instead
- **.history/** (1.4MB) - VS Code history, not needed in repo

### Duplicate/Obsolete Configuration
- **.zshrc** (12KB) - Managed by home-manager in home.nix
- **.tmux.conf** (4KB) - Managed by home-manager in home.nix
- **zshrc/** - Empty/duplicate directory

### Old Documentation
- **CLEANUP_SUMMARY.md** - Outdated cleanup notes
- **WSL_GUIDE.md** - Should be integrated into main README

### Unused Git Submodules
- **util-linux/** - Not referenced anywhere in configuration
- **base/** - All references are commented out

## Files to KEEP and Reorganize

### Core Configuration
- **flake.nix** - Simplify and modularize
- **flake.lock** - Keep as-is
- **home.nix** - Split into modules

### Documentation
- **README.md** - Update with new structure
- **CLAUDE.md** - Keep for AI assistance
- **.github/** - Keep GitHub workflows

### Scripts
- **apply.sh** - Simplify after modularization
- **deploy-remote.sh** - Keep for remote deployment
- **wsl-init.sh** - Extract to scripts/

### Shell Configurations
- **elvish/** - Keep and organize
- **carapace/** - Keep for completions
- **tmux/** - Keep tmux scripts
- **starship/** - Move config to config/

### Development Tools
- **nvim/** - Keep Neovim configuration
- **.vscode/** - Keep VS Code settings
- **.tool-versions** - Keep for asdf

### Other Configurations
- **atuin/** - Move to config/
- **termscp/** - Keep if used
- **tmuxinator/** - Keep if used
- **fonts/** - Remove after using Nix packages
- **ssh/** - Keep SSH configurations

## Files to EXTRACT from home.nix

### Embedded Scripts (via writeShellScriptBin)
1. **claude-code** wrapper (lines 222-225)
2. **apt-network-switch** (lines 228-339) - 100+ lines!

### Shell Functions
- Git aliases and functions
- Docker helpers
- Utility functions
- WSL-specific functions

### Large Configuration Blocks
- Bash configuration (361 lines)
- Zsh configuration (376 lines)
- Shell aliases (multiple blocks)

## Git Submodules Decision

### Keep (Conditionally Used)
- **stdlib.sh/** - Used in bash config, provides useful functions

### Remove
- **base/** - All usage is commented out
- **util-linux/** - Not used at all

## Directory Structure After Cleanup

```
BEFORE: ~50 files/directories in root
AFTER:  ~15 files/directories in root

Size reduction: ~28MB -> <2MB
```

## Immediate Actions

```bash
# 1. Remove large files
rm -f FiraCode.zip

# 2. Remove history
rm -rf .history/

# 3. Remove duplicate configs
rm -f .zshrc .tmux.conf
rm -rf zshrc/

# 4. Remove old docs
rm -f CLEANUP_SUMMARY.md WSL_GUIDE.md

# 5. Remove unused submodules
git submodule deinit util-linux
git rm util-linux
git submodule deinit base
git rm base

# 6. Clean git
git gc --aggressive
```

## Configuration Extraction Plan

### Scripts to Create
- `scripts/apt-network-switch.sh` - Network detection for Continental
- `scripts/claude-code-wrapper.sh` - Claude Code launcher
- `scripts/functions/git-helpers.sh` - Git functions
- `scripts/functions/docker-helpers.sh` - Docker functions
- `scripts/functions/utils.sh` - General utilities

### Modules to Create
- `modules/shells/bash.nix` - Bash-specific config
- `modules/shells/zsh.nix` - Zsh-specific config
- `modules/shells/elvish.nix` - Elvish-specific config
- `modules/dev/git.nix` - Git configuration
- `modules/cli/modern.nix` - Modern CLI tools

## Expected Benefits

1. **Repository size**: 28MB → <2MB (93% reduction)
2. **home.nix lines**: 1,292 → <100 (92% reduction)
3. **Root directory files**: ~50 → ~15 (70% reduction)
4. **Build time**: Faster due to modular evaluation
5. **Maintainability**: Much easier to find and update configs
6. **Git history**: Cleaner diffs, easier reviews