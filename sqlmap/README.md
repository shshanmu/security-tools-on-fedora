# Kali-based sqlmap Toolbox

This project provides an automated setup to build a [Kali Linux](https://www.kali.org) container running **sqlmap**, the industry-standard tool for automating the detection and exploitation of SQL injection flaws. By containerising sqlmap on Fedora, you keep your host system clean of Python dependencies while maintaining full performance.

## Features
*   **Persistent Sessions**: Automatically mounts your current working directory to `/data`, ensuring that scan logs, session files, and dumped data are saved directly to your host.
*   **Engine Agnostic**: Fully supports both **Podman** (Fedora default) and **Docker**.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts to ensure [Fedora SELinux compliance](https://docs.fedoraproject.org).
*   **Network Host Mode**: Uses `--network host` to allow the container to communicate directly with target servers or local proxies (like Burp Suite).

## Installation
1. Save the setup script as `setup-sqlmap.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-sqlmap.sh
3. Run the script:
   ```bash   
   ./setup-sqlmap.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
The tool is mapped to the sqlmap-bsd alias.
### 1. Basic URL Testing
Test a specific GET parameter for vulnerabilities:
   ```bash
   sqlmap-bsd -u "http://target.com" --banner
   ```
### 2. Database Enumeration
List all available databases on the target server:
   ```bash
   sqlmap-bsd -u "http://target.com" --dbs
   ```
### 3. Using Request Files
Test a complex request (POST, headers, cookies) saved from Burp Suite:
   ```bash
   sqlmap-bsd -r request.txt --level 5 --risk 3 --batch
   ```
## Maintenance & Uninstallation
Each setup script (setup-sqlmap.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-sqlmap.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest sqlmap GitHub updates from the Kali repositories:
   ```bash
   bash setup-sqlmap.sh
   ```
## Troubleshooting

- Proxy Support: To route traffic through a local proxy, use the --proxy flag:
  sqlmap-bsd -u "..." --proxy="http://127.0.0.1:8080"
- Output Directory: All session data is stored in the .sqlmap directory created in your current working folder.
- WAF Bypass: Consider using the --tamper flag to load scripts that help bypass Web Application Firewalls.

## License
sqlmap: Licensed under the GPLv2 License.
Setup Script: Licensed under the MIT License.