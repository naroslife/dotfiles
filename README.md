# Dotfiles Offline Installation Guide

This guide provides instructions for setting up this dotfiles environment on a machine that may not have direct internet access (referred to as the "restricted machine"). This is achieved by preparing a package on an internet-connected machine (the "unrestricted machine") and transferring it.

Two methods are presented:

1.  **Nix + Home Manager (Recommended):** A declarative approach using the Nix package manager and Home Manager module. This method defines the desired state and builds a reproducible environment package.
2.  **Custom Scripts (Alternative):** An imperative approach using custom shell scripts and Docker. This method runs the original setup process in a container, captures the resulting filesystem changes and packages, and replays them on the target machine.

## Prerequisites

**General:**

*   Git (on the unrestricted machine)
*   SSH client and server (for transferring files and remote execution, especially for the `deploy_offline_env.sh` script)
*   Basic Unix utilities (`tar`, `bash`, `sudo`) on both machines.

**For Nix + Home Manager Method:**

*   Nix package manager installed on both machines (see offline installation notes for the restricted machine).
*   Your dotfiles repository containing `flake.nix` and `home.nix`.

**For Custom Scripts Method:**

*   Docker (on the unrestricted machine)
*   `rsync` (on both machines)
*   `snap` command (on the unrestricted machine, *only* if downloading Snap packages via `config.sh`)

## Method 1: Nix + Home Manager (Recommended)

This method leverages Nix's declarative nature to build a reproducible environment package.

### Overview

1.  **Define:** Specify desired packages, configurations, and shell settings in `flake.nix` and `home.nix`.
2.  **Build:** Use `nix build` on the unrestricted machine to create the environment and gather all dependencies in the Nix store (`/nix/store`).
3.  **Export:** Use `nix copy` to export the environment and its dependencies (the "closure") to a local directory.
4.  **Transfer:** Package the exported closure and your Nix configuration files into tarballs and copy them to the restricted machine.
5.  **Import:** Use `nix copy` on the restricted machine to load the closure into its local Nix store from the transferred files.
6.  **Activate:** Use `home-manager switch` on the restricted machine to apply the configuration, creating symlinks and setting up the environment using the imported packages.

### Steps

**Phase 1: Preparation (Unrestricted Machine)**

1.  **Install Nix:**
    *   Follow the official instructions at [nixos.org](https://nixos.org/download.html). The multi-user installation is generally recommended:
        ```bash
        sh <(curl -L https://nixos.org/nix/install) --daemon
        ```
    *   Restart your shell or source the appropriate profile file as instructed.

2.  **Get Configuration:**
    *   Clone your dotfiles repository: `git clone <your-repo-url> dotfiles`
    *   `cd dotfiles` (Navigate into the directory containing `flake.nix`).

3.  **Build Environment:**
    *   Run the build command (replace `your_username` if needed):
        ```bash
        nix build .#homeConfigurations.your_username.activationPackage
        ```
    *   This creates a `./result` symlink pointing to the build output in `/nix/store`.

4.  **Export Closure:**
    *   Create an export directory: `mkdir ./nix-export`
    *   Copy the closure to the export directory:
        ```bash
        nix copy --to file://$(pwd)/nix-export ./result
        ```

5.  **Package Files:**
    *   Package the exported Nix closure:
        ```bash
        tar czf nix-export.tar.gz nix-export
        ```
    *   Package your Nix configuration and related dotfiles:
        ```bash
        # Adjust the list to include all files/dirs managed by home.nix
        tar czf dotfiles-config.tar.gz flake.nix home.nix .gitconfig .bashrc .profile elvish/ nvim/ tmux/ starship/ atuin/ bat/ navi/ ...
        ```

**Phase 2: Transfer**

6.  **Copy Packages:**
    *   Transfer `nix-export.tar.gz` and `dotfiles-config.tar.gz` to the restricted machine.

**Phase 3: Deployment (Restricted Machine)**

7.  **Install Nix (Offline):**
    *   The restricted machine *must* have Nix installed.
    *   *Easiest:* Temporarily connect to the internet to use the standard installer (see Step 1), then disconnect.
    *   *Offline:* Download the Nix static binary tarball on the unrestricted machine, transfer it, and follow Nix documentation for offline installation.

8.  **Prepare Files:**
    *   Copy the tarballs to a suitable location (e.g., `~`).
    *   Extract your configuration files:
        ```bash
        tar xzf dotfiles-config.tar.gz
        # Move the extracted files (flake.nix, etc.) to your desired config location
        # e.g., mkdir -p ~/.config/nixpkgs && mv flake.nix home.nix ... ~/.config/nixpkgs/
        ```
    *   Extract the Nix closure export:
        ```bash
        tar xzf nix-export.tar.gz
        ```

9.  **Import Closure:**
    *   Load packages into the local Nix store:
        ```bash
        nix copy --from file://$(pwd)/nix-export --all
        ```
    *   Clean up: `rm -rf nix-export nix-export.tar.gz`

10. **Activate Environment:**
    *   `cd` into the directory containing your `flake.nix`.
    *   Run the switch command (replace `your_username` if needed):
        ```bash
        home-manager switch --flake .#your_username
        ```

11. **(Optional) Change Login Shell:**
    *   If desired, use `chsh` to set your default login shell to one managed by Nix (e.g., Elvish):
        ```bash
        # Find the path (e.g., /nix/store/...)
        which elvish
        # Change shell (requires sudo)
        sudo chsh -s <path_to_elvish_binary> your_username
        ```

## Method 2: Custom Scripts (Alternative)

This method uses Docker on the unrestricted machine to simulate the setup process, capture installed files and packages, and create an installer script to replay this state on the restricted machine.

### Overview

1.  **Configure:** Edit `transfer/config.sh` to specify packages, user details, and directories to capture.
2.  **Prepare:** Run `transfer/prepare_offline_env.sh` on the unrestricted machine. This script:
    *   Builds a Docker image based on `config.sh`.
    *   Runs a container, installing packages (APT, Pip, Gem, Go, Cargo, NPM) and optionally executing the original `setup.sh`.
    *   Captures specified directories (`CAPTURE_DIRS`) from the container.
    *   Downloads specified Snap files, direct artifacts, and ASDF plugins.
    *   Generates an offline installer script (`install_offline.sh`).
    *   Packages everything into `offline_env_*.tar.gz`.
3.  **Deploy:** Transfer the package and run the `install_offline.sh` script on the restricted machine. This can be automated with `deploy_offline_env.sh` or done manually.

### Steps

1.  **Configuration:**
    *   Carefully review and edit `transfer/config.sh`.
    *   Define `TARGET_USER`, `TARGET_UID`, `TARGET_GID` to match the user on the restricted machine.
    *   List packages in `APT_PACKAGES`, `PIP_PACKAGES`, etc.
    *   Define `DIRECT_DOWNLOADS`, `SNAP_PACKAGES`, `ASDF_PLUGINS` if needed.
    *   Set `RUN_ORIGINAL_SETUP_SH="true"` if your main `setup.sh` performs actions beyond simple package installation (like running custom install scripts for zoxide, starship, etc.). Ensure `SETUP_SH_PATH` is correct.
    *   Verify `CAPTURE_DIRS` includes all locations modified by your setup (especially `/home/$TARGET_USER`, `/usr/local/bin`, `/opt`).

2.  **Preparation (Unrestricted Machine):**
    *   Ensure Docker is running.
    *   Navigate to the `transfer/` directory within your dotfiles repo.
    *   Run the preparation script:
        ```bash
        bash prepare_offline_env.sh
        ```
    *   This will take some time and create `offline_env_*.tar.gz` in your `$HOME` directory.

3.  **Deployment Option A: Automated Deployment (Recommended if SSH is available)**
    *   Use the `deploy_offline_env.sh` script located in the root of your dotfiles repository.
    *   This script automatically updates `transfer/config.sh` with your current user details, runs the preparation script (Step 2), transfers the package via `scp`, and executes the installation remotely via `ssh`.
    *   **Prerequisites:** Passwordless SSH access (via keys) configured from the unrestricted machine to the restricted machine.
    *   **Usage:**
        ```bash
        # Run from the root of your dotfiles repo
        ./deploy_offline_env.sh your_remote_user@remote_hostname_or_ip
        ```

4.  **Deployment Option B: Manual Deployment**
    *   **Transfer:** Manually copy the generated `offline_env_*.tar.gz` from `$HOME` on the unrestricted machine to the restricted machine.
    *   **Install (Restricted Machine):**
        *   Extract the package: `tar xzf offline_env_*.tar.gz`
        *   Navigate into the extracted directory: `cd offline_env_*`
        *   Review the installer script: `less scripts/install_offline.sh`
        *   Run the installer with sudo:
            ```bash
            sudo bash scripts/install_offline.sh
            ```
        *   Follow any manual instructions printed by the script (e.g., for installing Snap packages).
        *   Restart your shell or source `~/.bashrc`/`~/.profile`.

## Choosing a Method

*   **Nix + Home Manager:**
    *   **Pros:** Highly reproducible, declarative, atomic updates/rollbacks, excellent dependency management, better isolation. Aligns well with infrastructure-as-code principles.
    *   **Cons:** Steeper learning curve, requires Nix installation on the target machine (which itself might need an offline method), fundamentally different approach than traditional scripting.
*   **Custom Scripts:**
    *   **Pros:** Leverages existing `setup.sh` logic, potentially easier to understand initially if familiar with shell scripting and Docker, doesn't require Nix on the target.
    *   **Cons:** Less reproducible (depends on base Docker image matching target OS closely), capturing all side effects can be fragile, no atomic updates/rollbacks, managing dependencies manually.

For long-term maintainability and reproducibility, the **Nix + Home Manager** method is generally recommended if you are willing to invest in learning Nix. The **Custom Scripts** method can be a good starting point if you need to quickly adapt an existing imperative setup script for offline use.

## Troubleshooting

*   **Permissions:** Ensure file permissions are correct after transferring and extracting files. The installer scripts often use `sudo`.
*   **Paths:** Double-check paths in configuration files (`config.sh`, `flake.nix`, `home.nix`) and ensure they match your environment.
*   **Nix Offline Install:** Installing Nix itself on a truly offline machine can be challenging. Consult the Nix documentation for specific strategies.
*   **Script Errors:** Check logs (`/tmp/dotfiles_errors_*.log` for `setup.sh`, output of `prepare_offline_env.sh` and `install_offline.sh`) for detailed error messages.
*   **Docker Issues:** Ensure the Docker daemon is running and you have permissions to use it. Check network settings if Docker builds fail.