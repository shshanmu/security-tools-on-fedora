# Mimikatz & Pypykatz Suite (Kali-based)

This project provides a dual-engine containerized environment for running the original **Mimikatz** (via Wine) and the native Python **pypykatz** implementation on Fedora. This setup allows you to perform offline analysis of Windows credential dumps and Kerberos tickets without installing complex Windows compatibility layers directly on your host.

## Features
*   **Dual Engines**: 
    *   **Original Mimikatz**: The classic C-based [Mimikatz](https://github.com) binaries executed via [Wine](https://www.winehq.org).
    *   **pypykatz**: A pure-Python implementation of Mimikatz by [skelsec](https://github.com), which is significantly more stable for parsing LSASS dumps on Linux.
*   **Engine Agnostic**: Fully supports both **Podman** (Fedora default) and **Docker**.
*   **SELinux Aware**: Automatically applies the `:Z` flag to volume mounts for [Fedora security compliance](https://docs.fedoraproject.org).
*   **Architecture Support**: Includes `wine32` and `dpkg` configurations to support both x86 and x64 Windows binaries.

## Installation
1. Save the setup script as `setup-mimikatz.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-mimikatz.sh
3. Run the script:
   ```bash   
   ./setup-mimikatz.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
### 1. Pypykatz (Recommended for Linux)
Use pypykatz for parsing minidumps or registry hives natively. It is generally faster and more reliable than running the original binary via Wine.
   ```bash
   # Parse a local LSASS dump
    pypykatz-bsd lsa minidump lsass.dmp

    # Parse a SAM registry hive
    pypykatz-bsd registry SAM SYSTEM
   ```
### 2. Original Mimikatz (via Wine)
Use the original binary for specific sub-modules or interactive use.
   ```bash
   # Open interactive console
    mimikatz-bsd

    # Run specific commands and exit
    mimikatz-bsd "lsadump::sam" exit
   ```
## Maintenance & Uninstallation
Each setup script (setup-mimikatz.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-mimikatz.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest mimikatz GitHub updates from the Kali repositories:
   ```bash
   bash setup-mimikatz.sh
   ```
## Troubleshooting
- Wine Warnings: You may see fixme or err messages in the console. These are standard Wine debug logs and can usually be ignored as long as the Mimikatz prompt appears.
- Permissions: Files created by the container (like log files) will be accessible in your current host directory.
- Offline Only: Note that because these tools are containerized on Linux, they cannot interact with your Fedora host's live memory or LSASS. They are strictly for offline forensic analysis.

## License
Mimikatz: Creative Commons Attribution-NonCommercial 4.0 International.
pypykatz: Licensed under the MIT License.
Setup Script: Licensed under the MIT License.