# Kali-based PowerSploit Container

This project provides an automated script to build a [Kali Linux](https://www.kali.org) container pre-configured with **PowerShell Core (pwsh)** and the **PowerSploit** post-exploitation framework. It handles engine detection (Podman/Docker) and SELinux permissions for Fedora users.

## Purpose
[PowerSploit](https://github.com) is a collection of Microsoft PowerShell modules that can be used to aid penetration testers during all phases of an assessment. Since these scripts can trigger local antivirus flags on the host, running them inside a containerized Kali environment provides a layer of isolation.

## Installation
1. Save the setup script as `setup-powersploit.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-powersploit.sh


