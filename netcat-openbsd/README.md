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
   ```

## Features
- **Engine Agnostic:** Automatically detects and uses podman or docker.
- **SELinux Aware:** On Fedora/RHEL systems, the script detects if SELinux is Enforcing and automatically appends the :Z flag to volume mounts to prevent "Permission Denied" errors.
- **Volume Mounting:** Your current working directory is mapped to /data inside the container.
- **User Mapping::wq** Uses --user $(id -u):$(id -g) so that files received or modified by netcat are owned by your host user, not root.

## File Transfers & Volume Mounting
The aliases are configured to mount your current working directory ($(pwd)) to /data inside the container. This allows you to send or receive files directly.

**Example: Sending a file**
   ```bash
   nc-bsd 192.168.1.10 1234 < my_local_file.txt
   ``` 
**Example: Receiving a file**
  ```bash
  nc-bsd -l -p 1234 > incoming_data.txt
  ```
Note: Because the container runs as root by default, files redirected into a file via the shell (like the example above) will be owned by your user, but files written directly by the container process to /data will be owned by root.

## How It Works
- Base Image: kalilinux/kali-rolling
- Binary: Explicitly targets /usr/bin/nc.openbsd.
- Networking: Uses --network host so the containerized tool behaves as if it were installed natively on your Fedora host.
- Storage: Uses -v "$(pwd):/data" to bridge your current directory into the container environment.

## License
You can find the License file in the LICENSES folder in the repo.
