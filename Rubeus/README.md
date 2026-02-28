# Kali-based Rubeus Toolbox (Mono-Engine)

This project provides an automated setup to build a [Kali Linux](https://www.kali.org) container running **Rubeus**, the specialized C# toolset for raw Kerberos interaction and abuses. Since Rubeus is a Windows-native binary, this container uses **Mono** (an open-source .NET runtime) to execute it on your Fedora host.

## Features
*   **Mono Integration**: Pre-configures the [Mono Runtime](https://www.mono-project.com) to execute the Windows `Rubeus.exe` on Linux.
*   **Engine Agnostic**: Supports both **Podman** (Fedora default) and **Docker**.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts to ensure file access on Fedora.
*   **Network Host Mode**: Uses `--network host` to allow raw Kerberos traffic (Port 88) to reach Domain Controllers directly from your host.
*   **Isolated Environment**: Keeps the heavy `mono-complete` dependencies (over 500MB) detached from your Fedora base system.

## Installation
1. Save the setup script as `setup-rubeus.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-rubeus.sh
3. Run the script:
   ```bash   
   ./setup-rubeus.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
The tool is mapped to the rubeus-bsd alias.
### AS-REP Roasting
Harvest hashes for users with "Do not require Kerberos preauthentication" enabled:
  ```bash
  rubeus-bsd asreproast /domain:example.com /dc:10.0.0.1 /format:hashcat /outfile:hashes.txt
  ```
### Kerberoasting
Request service tickets and extract crackable hashes:  
  ```bash
  rubeus-bsd kerberoast /domain:example.com /dc:10.0.0.1 /outfile:krbroast.txt
  ```
### Brute Forcing
Test a list of passwords against a specific user:
  ```bash
  rubeus-bsd brute /user:jdoe /password:Welcome123 /domain:example.com
  ```

## Maintenance & Uninstallation
Each setup script (setup-rubeus.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-rubeus.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest Impacket GitHub updates from the Kali repositories:
   ```bash
   bash setup-rubeus.sh
   ```

## Troubleshooting
- LSA Limitations: Because Linux has no Local Security Authority (LSA), commands like ptt (Pass-the-Ticket), triage, and dump will not work. Use this container primarily for roasting and hash generation.
- Firewalld: Ensure your Fedora Firewall allows outgoing traffic on Port 88 (TCP/UDP) to reach the Domain Controller.
- Output Files: The container mounts your current directory to /data. All files specified with /outfile: will appear in your host's working directory.

## License
Rubeus: Licensed under a modified Apache Software License.
Setup Script: Licensed under the MIT License.