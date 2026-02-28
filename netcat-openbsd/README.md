# Kali-based OpenBSD Netcat Container

This project provides a script to build a specialized [Kali Linux](https://www.kali.org) Docker container running the **OpenBSD** version of `netcat`. It automatically configures aliases on your Fedora host so you can use the OpenBSD variant seamlessly without conflicting with your system's default `nmap-ncat`.

## Purpose
Fedora and Kali handle `netcat` differently. This setup ensures that when you run `nc-bsd`, you are strictly using the OpenBSD rewrite, which includes specific features documented in the [OpenBSD Manual Pages](https://man.openbsd.org):
*   **-U**: Unix Domain Socket support.
*   **-z**: Zero-I/O mode (used for scanning).
*   **-S**: TCP MD5 signature support.

## Installation
1. Save the setup script as `setup-nc.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-nc.sh
   ./setup-nc.sh
3. Run the script:
   ```bash
   bash setup-nc.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   
## Usage
The script creates two aliases that use the --network host flag, allowing the container to interact with your host machine's network stack directly via the any OCI compliant container engine like Docker or Podman.

   ```bash
   # Get help and verify the version
   nc-bsd -h
   
   # Scan a range of ports
   nc-bsd -zv 127.0.0.1 20-80
   
   # Listen on a port
   nc-bsd -l -p 8080


