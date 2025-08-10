# WSL Setup Guide

## WSL-Specific Features Added

### 🔧 WSL Utilities
- **wslu**: Essential WSL utilities package
  - `wslview <file>` - Open files in Windows default applications
  - `wslpath <path>` - Convert between Windows and WSL paths
  - `wslvar <variable>` - Access Windows environment variables

### 📋 Clipboard Integration
- **xclip** and **wl-clipboard** for Linux clipboard
- **Windows clipboard aliases**:
  - `pbcopy` - Copy to Windows clipboard (uses clip.exe)
  - `pbpaste` - Paste from Windows clipboard

### 🌐 Cross-Platform Compatibility
- **Git configuration** optimized for WSL:
  - `core.autocrlf = "input"` - Proper line ending handling
  - `core.safecrlf = true` - Warnings for mixed line endings

### 🚀 Performance Optimizations
- `WSLENV` variable for proper environment variable passing
- Proper umask settings for Windows compatibility
- Optimized temporary directory usage

## WSL-Specific Commands

### File Operations
```bash
# Open file in Windows default app
wslview document.pdf

# Convert paths
wslpath "C:\Users\username\Documents"  # → /mnt/c/Users/username/Documents
wslpath -w /home/user/file.txt         # → \\wsl$\Ubuntu\home\user\file.txt

# Access Windows environment variables
wslvar PATH
wslvar USERPROFILE
```

### Clipboard Operations
```bash
# Copy to Windows clipboard
echo "Hello WSL" | pbcopy

# Paste from Windows clipboard
pbpaste
```

### Network and System
```bash
# Access Windows services from WSL
cmd.exe /c "net start service-name"

# Open Windows Explorer in current directory
explorer.exe .
```

## Tips for WSL Development

1. **File System Performance**: Keep frequently accessed files in WSL filesystem (`/home/`) for better performance
2. **Git Repositories**: Clone repos in WSL filesystem, not Windows drives
3. **Docker**: Use Docker Desktop for Windows with WSL 2 backend
4. **VS Code**: Use `code .` to open projects in VS Code from WSL
5. **Node.js/Python**: Install in WSL, not Windows, for better package management

## Troubleshooting

### Common Issues
- **Permission errors**: Check umask and file permissions
- **Line ending issues**: Ensure git `core.autocrlf` is set to "input"
- **Path problems**: Use `wslpath` to convert between Windows and WSL paths
- **Clipboard not working**: Ensure Windows clipboard service is running

### Performance Tips
- Use WSL 2 (not WSL 1) for better performance
- Keep development files in WSL filesystem
- Use Windows Terminal for better terminal experience
- Consider enabling systemd if needed: `sudo systemctl enable --now systemd`
