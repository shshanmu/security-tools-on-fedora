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

## License
This container includes PowerSploit, which is licensed under the **BSD 3-Clause** License.
The Dockerfile and build scripts are licensed under the **MIT License**:

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.