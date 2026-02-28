# Kali-based PowerSploit Container

This project provides an automated script to build a [Kali Linux](https://www.kali.org) container pre-configured with **PowerShell Core (pwsh)** and the **PowerSploit** post-exploitation framework. It handles engine detection (Podman/Docker) and SELinux permissions for Fedora users.

## Purpose
[PowerSploit](https://github.com) is a collection of Microsoft PowerShell modules that can be used to aid penetration testers during all phases of an assessment. Since these scripts can trigger local antivirus flags on the host, running them inside a containerized Kali environment provides a layer of isolation.

## Installation
1. Save the setup script as `setup-powersploit.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-powersploit.sh
3. Run the script:
   ```bash 
   ./setup-powersploit.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```
## Usage
Run the alias to start an interactive PowerShell session:
   ```bash
   powersploit-bsd
   ```
## Accessing PowerSploit Modules
   ```bash
   # Example: Importing PowerView for Reconnaissance
   Import-Module /usr/share/powersploit/Recon/PowerView.ps1

   # Example: Using Get-NetDomain
   Get-NetDomain
   ```
## Features
- **Engine Agnostic:** Automatically detects and uses podman or docker.
- **SELinux Aware:** On Fedora/RHEL systems, the script detects if SELinux is Enforcing and automatically appends the :Z flag to volume mounts to prevent "Permission Denied" errors.
- **Persistence:** Mounts your current working directory to /data so you can load your own scripts or save output.
- **Safe Permissions:** Runs with your host UID/GID (--user) so files created in the container aren't locked as root.

## How It Works
- Base Image: kalilinux/kali-rolling
- Packages: Installs powershell and powersploit via apt.
- Network: Uses --network host to allow network discovery from within the PowerShell session.

## Troubleshooting
If you encounter issues while running the PowerSploit or Netcat containers, refer to the solutions below.

1. "Command Not Recognized" (e.g., Get-NetDomain)
If you enter the container but cannot run PowerSploit commands:

    - Check the Loader: Ensure you saw the green ✅ PowerSploit Core Loaded! message upon entry. If not, the profile may have failed.
    - Manual Force-Load: You can manually dot-source the scripts within the session:
    ```powershell
    . /usr/share/windows-resources/powersploit/Recon/PowerView.ps1
    ```
    - Verify Files: Ensure the files exist in the Kali image:
    ```powershell
    Test-Path /usr/share/windows-resources/powersploit/Recon/PowerView.ps1
    ```
2. "Operation Not Supported on This Platform"
You will see red error text during the loading process (especially for PowerUp or Mimikatz).

    Cause: These scripts attempt to check Windows-specific APIs (WMI, Registry, Access Tokens) that do not exist on Linux.
    Solution: Ignore these errors. The functions (like Get-NetDomain) will still load into memory. They are intended for use against remote Windows targets, not the local container environment.

3. Permission Denied / History File Errors
If you see errors regarding ConsoleHost_history.txt or access to /data/.local:

    SELinux: Ensure you ran the setup script on Fedora with SELinux enabled; it adds the :Z flag to the volume mount.
    Home Directory: The script sets ENV HOME=/tmp inside the Dockerfile to prevent PowerShell from trying to write config files to your host's current directory. If you manually modified the alias, ensure this environment variable is set.

4. Files Created by Container are Owned by Root
If you save a scan result and cannot delete it from your Fedora host:

    Solution: The alias includes --user $(id -u):$(id -g). If you removed this, the container defaults to the root user. You can reclaim ownership on your host with:
   ```bash
   sudo chown -R $USER:$USER .
   ```
5. Network Connectivity Issues
If nc-bsd cannot see local services or powersploit-bsd cannot reach a DC:

    Solution: Ensure the alias includes --network host. This allows the container to share the Fedora host's IP and network interfaces directly.

## License
This container includes PowerSploit, which is licensed under the **BSD 3-Clause** License.
The Dockerfile and build scripts are licensed under the **MIT License**:

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.