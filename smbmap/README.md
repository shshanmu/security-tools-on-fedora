# Kali-based SMBMap Toolbox

This project provides an automated, containerised setup for **SMBMap**, a specialized tool for enumerating SMB shares across entire domains. By running this inside a [Kali Linux](https://www.kali.org) container on Fedora, you avoid complex Python dependency conflicts and maintain a clean host environment.

## Features
*   **Mass Enumeration**: Quickly identify SMB shares, permissions, and file contents across multiple hosts.
*   **Engine Agnostic**: Fully compatible with **Podman** (Fedora default) and **Docker**.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts for [Fedora security compliance](https://docs.fedoraproject.org).
*   **Network Host Mode**: Uses `--network host` to ensure the tool can interact directly with your local network for discovery.
*   **Persistence**: Your current directory is mapped to `/data`, so any files downloaded via SMB appear instantly on your host.

## Installation
1. Save the setup script as `setup-smbmap.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-smbmap.sh
3. Run the script:
   ```bash   
   ./setup-smbmap.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
The tool is mapped to the smbmap-bsd alias.
### 1. Basic Share Discovery (Guest)
List all available shares on a target host:
   ```bash
   smbmap-bsd -H 192.168.1.50
   ```
### 2. Authenticated Enumeration
Check permissions for a specific user across a domain:
   ```bash
   smbmap-bsd -H 192.168.1.50 -u "admin" -p "P@ssword123" -d "CORP.local"
   ```
### 3. Executing Commands
If you have administrative rights, you can execute commands on the target:
   ```bash
   smbmap-bsd -H 192.168.1.50 -u "admin" -p "P@ssword123" -x "whoami"
   ```
### 4. File Downloads
Download a specific file from a share directly to your current Fedora directory:
   ```bash
   smbmap-bsd -H 192.168.1.50 -r "C$" --download "Users\Admin\Desktop\secrets.txt"
   ```
## Maintenance & Uninstallation
Each setup script (setup-smbmap.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-smbmap.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest smbmap GitHub updates from the Kali repositories:
   ```bash
   bash setup-smbmap.sh
   ```
## Troubleshooting
- Connection Errors: Ensure your Fedora Firewalld allows outgoing traffic on Port 445 (TCP).
- Authentication: If testing local Windows accounts, use -d . to specify the local machine as the provider.
- Python Dependencies: This container includes python3-cryptography to ensure modern NTLM/SMB3 encryption is supported.

## License
SMBMap: Licensed under the GPLv3 License.
Setup Script: Licensed under the MIT License.