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
3. Run the script:
   ```bash   
   ./setup-nc.sh
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

## Features
- **Engine Agnostic:** Automatically detects and uses podman or docker.
- **SELinux Aware:** On Fedora/RHEL systems, the script detects if SELinux is Enforcing and automatically appends the :Z flag to volume mountbash s to prevent "Permission Denied" errors.
- **Volume Mounting:** Your current working directory is mapped to /data inside the container.
- **User Mapping::wq** Uses --user $(id -u):$(id -g) so that files received or modified by netcat are owned by your host user, not root.

## How It Works
- Base Image: kalilinux/kali-rolling
- Binary: Explicitly targets /usr/bin/nc.openbsd.
- Networking: Uses --network host so the containerized tool behaves as if it were installed natively on your Fedora host.
- Storage: Uses -v "$(pwd):/data" to bridge your current directory into the container environment.

## Maintenance & Uninstallation
Each setup script (setup-nc.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-nc.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```
### SELinux & Permissions
If you encounter Permission Denied when accessing host files:

    The :Z Flag: The scripts automatically detect if SELinux is Enforcing and append the :Z label to volume mounts. If you move the aliases to a different machine, ensure this flag is present in the podman run command.

## License
You can find the License file in the LICENSES folder in the repo.
