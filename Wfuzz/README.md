# Kali-based Wfuzz Toolbox (Fixed for Python 3.13)

This project provides an automated setup to build a [Kali Linux](https://www.kali.org) container running **Wfuzz**, a highly modular web application fuzzer. This version includes specific fixes for the `ModuleNotFoundError: No module named 'pkg_resources'` and `Pycurl SSL` warnings common in newer Python 3.13 environments.

## Features
*   **Python 3.13 Compatibility**: Includes `python3-setuptools` to restore the missing `pkg_resources` module required by Wfuzz.
*   **Full SSL Support**: Includes `libcurl4-openssl-dev` to ensure `pycurl` works correctly for HTTPS/SSL fuzzing.
*   **Engine Agnostic**: Supports both **Podman** (Fedora default) and **Docker**.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts to ensure file access on Fedora.
*   **Standard Wordlists**: Installs the default [Kali wordlists](https://www.kali.orgtools/wordlists/) (Dirb, Wfuzz, etc.) inside the container.

## Installation
1. Save the setup script as `setup-wfuzz.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-wfuzz.sh
3. Run the script:
   ```bash   
   ./setup-wfuzz.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
The tool is mapped to the wfuzz-bsd alias. All Kali wordlists are available at /usr/share/wordlists/.
### Directory Discovery
Fuzz for common directories and hide 404 responses:
   ```bash
   wfuzz-bsd -c -w /usr/share/wordlists/dirb/common.txt --hc 404 http://example.com/FUZZ
   ```
### Parameter Fuzzing
Test for hidden URL parameters:
   ```bash
   wfuzz-bsd -c -z list,id-user-admin http://example.com/page.php?FUZZ=1
   ```
### POST Data Fuzzing
Fuzz a login form for SQL injection strings:
   ```bash
   wfuzz-bsd -c -w /usr/share/wordlists/wfuzz/Injections/SQL.txt -d "uname=admin&pass=FUZZ" http://example.com/login.php
   ```
## Maintenance & Uninstallation
Each setup script (setup-wfuzz.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-wfuzz.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest wfuzz GitHub updates from the Kali repositories:
   ```bash
   bash setup-wfuzz.sh
   ```

## Troubleshooting

- Missing pkg_resources: If you see this error, ensure you are using the updated setup-wfuzz.sh which installs python3-setuptools.
- Pycurl SSL Warning: This is resolved by the libcurl4-openssl-dev package included in the Dockerfile.
- Output Files: The container mounts your current directory to /data. Results exported to files will appear in your host's working directory.

## License
Wfuzz: Licensed under the GPL v2 License.
Setup Script: Licensed under the MIT License.