# Kali-based Impacket Toolbox

This project provides an automated setup to build a [Kali Linux](https://www.kali.org) container containing the full [Impacket](https://www.kali.orgtools/impacket-scripts/) library and its scripts. It dynamically generates over 60 native-feeling aliases for Fedora, allowing you to run tools like `secretsdump` or `ntlmrelayx` without installing Python dependencies on your host.

## Features
*   **Dynamic Indexing**: The script scrapes the Kali container for every available `impacket-*` tool and creates a corresponding `-bsd` alias.
*   **Engine Agnostic**: Supports both **Podman** (Fedora default) and **Docker**.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts to ensure file access on Fedora.
*   **Network Host Mode**: Uses `--network host` to allow tools like `ntlmrelayx` and `smbserver` to bind to your host's physical network interfaces.
*   **Isolated Environment**: Prevents "dependency hell" by keeping Impacket’s specific Python requirements inside the container.

## Installation
1. Save the setup script as `setup-impacket.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-impacket.sh
3. Run the script:
   ```bash   
   ./setup-impacket.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
All tools are prefixed with impacket- and suffixed with -bsd.
### Remote Execution
  ```bash
   # Execute a command via WMI
   impacket-wmiexec-bsd DOMAIN/User:Password@192.168.1.50
   ```
### Credential Dumping
  ```bash
   # Dump hashes from a Domain Controller (requires appropriate privileges)
   impacket-secretsdump-bsd DOMAIN/Admin:Password@10.0.0.1
   ```
### Network Relaying
  ```bash
   # Relay NTLM authentications to a target (may require sudo for port 445)
   sudo impacket-ntlmrelayx-bsd -t smb://192.168.1.20 -smb2support
   ```
## Maintenance & Uninstallation
Each setup script (setup-impacket.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-impacket.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest Impacket GitHub updates from the Kali repositories:
   ```bash
   bash setup-impacket.sh
   ```

## Troubleshooting

- Privileged Ports: On Fedora, binding to ports below 1024 (like 445 for SMB) requires root. Run the alias with sudo if needed.
- Firewalld: If you aren't receiving incoming connections (Relays/SMBServer), ensure your Fedora Firewall is configured to allow those ports.
- Output Files: The container mounts your current directory to /data. All logs or dumped hashes will be saved to your host's working directory.

## License
Impacket: Licensed under a modified Apache Software License.
Setup Script: Licensed under the MIT License.