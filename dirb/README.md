# Web Discovery Suite (DIRB, DirBuster, & SecLists)

This project provides an automated setup to build a [Kali Linux](https://www.kali.org) container featuring a complete web content discovery suite. It includes the classic **DIRB** (CLI), the multi-threaded **DirBuster** (GUI), and the massive **SecLists** wordlist collection.

The setup is specifically hardened for **Fedora**, automatically detecting whether you are using **Wayland** or **X11** to ensure GUI applications render correctly without manual configuration.

## Features
*   **Dual-Mode GUI Support**: Automatically detects **Wayland** or **X11** and configures the [XWayland bridge](https://wayland.freedesktop.org) or X11 socket accordingly.
*   **Automated Permissions**: The `dirbuster-bsd` alias automatically runs `xhost +local:$(whoami)` to grant display permissions, reducing manual steps.
*   **Massive Wordlist Library**: Includes the full [SecLists](https://www.kali.orgtools/seclists/) repository (~1.5GB) and standard Kali wordlists.
*   **Engine Agnostic**: Supports both **Podman** and **Docker**.
*   **SELinux Hardened**: Applies the `:Z` label and `container_runtime_t` security options for [Fedora SELinux compliance](https://docs.fedoraproject.org).

## Installation
1. Save the setup script as `setup-dirb.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-dirb.sh
3. Run the script:
   ```bash   
   ./setup-dirb.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage

## 1. DIRB (Command Line)
Scan a target using the built-in SecLists common discovery list:
   ```bash
   dirb-bsd http://target.com /usr/share/seclists/Discovery/Web-Content/common.txt
   ```
## 2. DirBuster (Graphical User Interface)
Scan a target using the built-in SecLists common discovery list:
   ```bash
   dirbuster-bsd
   ```
Note: In the GUI, browse to /usr/share/seclists/ to select your preferred wordlists.

## Maintenance & Uninstallation
Each setup script (setup-dirb.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-dirb.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest dirb GitHub updates from the Kali repositories:
   ```bash
   bash setup-dirb.sh
   ```

## Troubleshooting
- Display Issues: If the GUI fails to open, ensure xhost is installed on your host: sudo dnf install xhost.
- High Disk Usage: This image is large (~2GB) because it contains the entire SecLists collection.
- Scanning Speed: Use the -t flag in DIRB or adjust the thread count in DirBuster to manage scan intensity.

## License
DIRB/DirBuster: GPLv2.
SecLists: MIT License.
Setup Script: Licensed under the MIT License.