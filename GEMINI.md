# Directory Overview

This directory contains a collection of dotfiles for configuring a development environment across macOS, Linux, and Windows. It includes settings for various shells, editors, and command-line tools, aiming for a consistent experience across different operating systems.

## Key Files and Configurations

This repository is structured to manage configurations for several applications and environments. Here are some of the key components:

*   **Shell Configuration (`zsh`, `pwsh`, `starship`):**
    *   `zsh/.zshrc`: Configures the Z shell (`zsh`) using `oh-my-zsh` and plugins like `zsh-autosuggestions` and `zsh-syntax-highlighting`. It defines numerous aliases for common commands (e.g., `git`, `ls`, `ssh`) and integrates tools like `fzf` for fuzzy finding and `zoxide` for directory navigation.
    *   `starship/.config/starship.toml`: Provides a highly customized, cross-shell prompt using Starship, with a `gruvbox_dark` theme and icons for different operating systems and development tools.
    *   `pwsh/`: Contains configuration scripts for PowerShell.

*   **Neovim Configuration (`nvim`):**
    *   `nvim/.config/nvim/init.lua`: The entry point for the Neovim configuration. The configuration is written in Lua and is structured modularly in the `lua/` subdirectory, covering plugins, keymaps, and editor options.

*   **Git Configuration (`git`):**
    *   `git/.gitconfig`: Configures Git with user details, aliases, and integrates Visual Studio Code as the default editor, diff tool, and merge tool.

*   **Terminal and GUI Configuration (`kitty`, `ghostty`, `hyprland`, `waybar`):**
    *   `kitty/.config/kitty/kitty.conf`: Configuration for the Kitty terminal emulator.
    *   `ghostty/.config/ghostty/config`: Configuration for the Ghostty terminal emulator.
    *   `hyprland/.config/hypr/hyprland.conf`: Configuration for the Hyprland Wayland compositor, defining window management, aesthetics, and keybindings for a Linux desktop environment.
    *   `waybar/.config/waybar/config`: Configuration for the Waybar status bar, used with Hyprland.

*   **Cross-Platform and OS-Specific Settings (`osx`, `wsl`, `windows`):**
    *   `osx/`: Contains macOS-specific settings, including Karabiner Elements configurations for advanced key remapping.
    *   `wsl/.wslconfig`: Configuration for the Windows Subsystem for Linux (WSL).
    *   `script/`: Contains setup scripts (`setup.sh`, `setup.bat`) likely used for bootstrapping the environment on a new machine.

## Usage

These dotfiles are used to set up and maintain a personalized development environment. The setup process likely involves:

1.  Cloning this repository to a user's home directory.
2.  Using a tool like `stow` (as mentioned in the `README.md`) to create symbolic links from the files in this repository to their corresponding locations in the home directory (e.g., `~/.zshrc`, `~/.config/nvim/`).
3.  Running the setup scripts in the `script/` directory to install necessary tools and apply configurations.

The configurations are designed to be modular, allowing for easy management and version control of the entire development environment setup.
