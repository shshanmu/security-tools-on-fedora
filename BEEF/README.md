# Kali-based BeEF (Browser Exploitation Framework)

This project provides an automated, containerised setup for the [Browser Exploitation Framework (BeEF)](https://www.kali.org) on Fedora. It includes deep-level fixes for the Ruby 3.x dependency chain (EventMachine, Msgpack, SQLite3, and Thin) that often crash standard Kali Docker images.

## Features
*   **Dependency Reconstruction**: Uses `bundle exec` and manual gem injection to fix `LoadError` crashes caused by broken Ruby paths in rolling distributions.
*   **Automated Credentials**: Pre-configures the mandatory non-default credentials (`admin` / `ChangeMe123!`) required for BeEF to initialize.
*   **Engine Agnostic**: Fully compatible with **Podman** (Fedora default) and **Docker**.
*   **Network Host Mode**: Uses `--network host` to ensure the hook scripts and Admin UI are accessible via your Fedora host's physical IP.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts for [Fedora security compliance](https://docs.fedoraproject.org).

## Installation
1. Save the setup script as `setup-beef.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-beef.sh
3. Run the script:
   ```bash   
   ./setup-beef.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
Launch the framework using the custom alias:
   ```bash
   beef-bsd
   ```
### Accessing the Framework
Once the banner appears and the "BeEF is loading" process completes:

    Admin UI: 127.0.0.1
    Default User: admin
    Default Pass: ChangeMe123!

### Hooking a Target
To hook a browser, point it to your Fedora host's IP on port 3000. You can test this locally using the built-in demo page:

http://127.0.0.1

## Maintenance & Uninstallation
Each setup script (setup-beef.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-beef.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest beef GitHub updates from the Kali repositories:
   ```bash
   bash setup-beef.sh
   ```
## Troubleshooting
- Thin/EventMachine Errors: This setup uses bundle exec specifically to prevent LoadError: cannot load such file -- thin. If errors persist, run the uninstall command and rebuild to refresh the gem lockfile.
- Firewall Configuration: Ensure Fedora Firewalld is not blocking port 3000:
sudo firewall-cmd --add-port=3000/tcp --temporary
- Persistence: Note that hooked browser data is stored in a temporary SQLite database inside the container. If you stop the container, current sessions are lost.

## License
BeEF: Licensed under the GPL-2.0 License.
Setup Script: Licensed under the MIT License.