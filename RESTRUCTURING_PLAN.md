# Dotfiles Repository Restructuring Plan

## Current Issues

1. **Monolithic home.nix** - 1,292 lines making it hard to maintain
2. **Embedded scripts** - Shell scripts and functions embedded as strings in Nix files
3. **Dead code** - Unused files (.zshrc, .tmux.conf) managed via home-manager
4. **Large binary files** - 27MB FiraCode.zip unnecessarily in repo
5. **History pollution** - .history folder with 1.4MB of old file versions
6. **Poor modularity** - Everything in one file instead of logical modules
7. **Mixed concerns** - Configuration, scripts, and logic all together

## Proposed Architecture

```
dotfiles/
├── flake.nix                 # Minimal flake with imports
├── flake.lock               # Lock file
├── README.md                # Documentation
├── CLAUDE.md               # AI assistant instructions
├── apply.sh                # Setup script (simplified)
│
├── modules/                # Modular Nix configurations
│   ├── default.nix        # Main module that imports all others
│   ├── core.nix          # Core packages and basic setup
│   ├── shells/           # Shell-specific configs
│   │   ├── default.nix   # Shell module aggregator
│   │   ├── bash.nix      # Bash configuration
│   │   ├── zsh.nix       # Zsh configuration
│   │   └── elvish.nix    # Elvish configuration
│   ├── dev/              # Development tools
│   │   ├── default.nix   # Dev module aggregator
│   │   ├── languages.nix # Language-specific tools
│   │   ├── containers.nix # Docker, k8s tools
│   │   ├── git.nix       # Git configuration
│   │   └── editors.nix   # Neovim, etc.
│   ├── cli/              # CLI tools and utilities
│   │   ├── default.nix   # CLI module aggregator
│   │   ├── modern.nix    # Modern CLI replacements (bat, eza, etc.)
│   │   └── productivity.nix # Productivity tools
│   └── wsl.nix           # WSL-specific configuration
│
├── scripts/               # Extracted shell scripts
│   ├── apt-network-switch.sh
│   ├── wsl-init.sh
│   ├── functions/        # Shell functions library
│   │   ├── git.sh        # Git helper functions
│   │   ├── docker.sh     # Docker helpers
│   │   └── utils.sh      # General utilities
│   └── bin/              # User scripts installed to PATH
│       └── (various user scripts)
│
├── config/                # Static configuration files
│   ├── starship.toml    # Starship prompt config
│   ├── atuin.toml       # Atuin config
│   ├── git/             # Git configuration
│   └── tmux/            # Tmux configuration
│
└── lib/                  # Nix helper functions
    └── helpers.nix       # Shared Nix functions

```

## Files to Remove

- **FiraCode.zip** (27MB) - Use Nix packages for fonts instead
- **.history/** - Version control history pollution
- **.zshrc** - Managed by home-manager
- **.tmux.conf** - Managed by home-manager
- **CLEANUP_SUMMARY.md** - Old documentation
- **WSL_GUIDE.md** - Integrate into README.md
- **base/** - Git submodule (if unused)
- **stdlib.sh/** - Git submodule (if unused)
- **util-linux/** - Git submodule (if unused)
- **zshrc/** - Duplicate directory

## Migration Strategy

### Phase 1: Clean Up (Immediate)
1. Remove large files and dead code
2. Clean .history directory
3. Remove unused git submodules

### Phase 2: Extract Scripts
1. Move embedded shell scripts to `scripts/` directory
2. Convert `writeShellScriptBin` to file references
3. Extract shell functions to separate files

### Phase 3: Modularize Configuration
1. Split home.nix into logical modules
2. Create module structure under `modules/`
3. Use Nix imports to compose configuration

### Phase 4: Organize Assets
1. Move static configs to `config/`
2. Organize shell-specific files
3. Create proper library structure

### Phase 5: Simplify Flake
1. Update flake.nix to use new module structure
2. Simplify user configuration
3. Remove duplicate configurations

## Key Improvements

### 1. Module System
```nix
# modules/default.nix
{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./core.nix
    ./shells
    ./dev
    ./cli
  ] ++ lib.optional (builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop) ./wsl.nix;
}
```

### 2. Extracted Scripts
```nix
# Instead of embedding:
home.packages = [
  (pkgs.writeShellScriptBin "apt-network-switch"
    (builtins.readFile ../scripts/apt-network-switch.sh))
];
```

### 3. Organized Shell Configs
```nix
# modules/shells/bash.nix
{ config, pkgs, lib, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ../../../scripts/functions/utils.sh;
    # ... rest of config
  };
}
```

### 4. Clean Package Management
```nix
# modules/core.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Group packages logically
    # Core utilities
    coreutils
    findutils

    # Network tools
    curl
    wget

    # ... etc
  ];
}
```

## Benefits

1. **Maintainability** - Logical separation makes updates easier
2. **Readability** - Find configurations quickly
3. **Reusability** - Modules can be selectively imported
4. **Version Control** - Cleaner diffs and history
5. **Performance** - Faster evaluation with smaller files
6. **Testing** - Easier to test individual modules
7. **Documentation** - Clear structure is self-documenting

## Implementation Order

1. **Day 1**: Clean repository, remove unnecessary files
2. **Day 2**: Extract scripts and functions
3. **Day 3-4**: Create module structure and split home.nix
4. **Day 5**: Test and refine configuration
5. **Day 6**: Update documentation

## Testing Strategy

1. Test in isolated environment first
2. Verify all shells work correctly
3. Check all tools are available
4. Ensure WSL-specific features work
5. Test on fresh system

## Success Criteria

- [ ] home.nix reduced to < 100 lines
- [ ] Each module < 200 lines
- [ ] No embedded shell scripts
- [ ] Repository size < 5MB
- [ ] Clean git history
- [ ] All features working
- [ ] Improved startup time