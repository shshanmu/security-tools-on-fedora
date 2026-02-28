i# Kali-based Kerberoast Toolbox (Nidem Scripts)

This project provides an automated setup to build a [Kali Linux](https://www.kali.org) container running the original **Kerberoast** python toolset by Tim Medin (@nidem). These scripts are essential for auditing Kerberos ticket security, specifically for performing "Kerberoasting" attacks and cracking TGS-REP tickets offline.

## Features
*   **Complete Toolset**: Includes all core scripts: `tgsrepcrack`, `kirbi2john`, `extracttgsrepfrompcap`, and `krbroast-pcap2hashcat`.
*   **Easy Identification**: Every command is prefixed with `kerberoast-` and suffixed with `-bsd` for easy tab-completion on your Fedora host.
*   **Engine Agnostic**: Supports both **Podman** (Fedora default) and **Docker**.
*   **SELinux Support**: Automatically applies the `:Z` flag to volume mounts to ensure file access.
*   **Python 3 Ready**: Uses the modern Kali package which is updated for Python 3 compatibility.

## Installation
1. Save the setup script as `setup-kerberoast.sh`.
2. Make it executable:
   ```bash
   chmod +x setup-kerberoast.sh
3. Run the script:
   ```bash   
   ./setup-kerberoast.sh
4. Reload your shell configuration:
   ```bash
   source ~/.bashrc
## Usage
Type kerberoast- and hit Tab to see all available tools.
### Cracking Service Tickets (TGS-REP)
Crack a captured .kirbi ticket using a wordlist:
   ```bash
   kerberoast-tgsrepcrack-bsd wordlist.txt ticket.kirbi
   ```
### Converting Tickets for Hashcat
Convert a PCAP file containing Kerberos traffic into a format ready for Hashcat:
   ```bash
   kerberoast-krbroast-pcap2hashcat-bsd traffic.pcap > hashes_for_hashcat.txt
   ```
### Converting Kirbi to John the Ripper
   ```bash
   kerberoast-kirbi2john-bsd ticket.kirbi > hashes_for_john.txt
   ```
## Maintenance & Uninstallation
Each setup script (setup-kerberoast.sh) now includes a built-in uninstaller to keep your host environment clean.
1. Uninstalling a Toolbox
To remove a specific toolbox, its associated container image, and its aliases from your ~/.bashrc, run the original setup script with the --uninstall flag:
  ```bash
  bash setup-kerberoast.sh --uninstall
  ```
2. Finalising Removal
After running an uninstaller, you must reload your shell configuration to clear the aliases from your current session:
```bash
source ~/.bashrc
```

### Updating the Image
To refresh the toolset with the latest kerberoast GitHub updates from the Kali repositories:
   ```bash
   bash setup-kerberoast.sh
   ```
## Troubleshooting

- Wordlists: Ensure your wordlists are in your current working directory, as the container mounts $(pwd) to /data.
- Output Redirection: When using tools like kirbi2john, use standard bash redirection (> output.txt) to save the results to your host machine.
- PCAP Extraction: If using extracttgsrepfrompcap, ensure the PCAP file is not corrupted and contains valid Kerberos TGS-REP packets.

## License
Kerberoast: Licensed under the MIT License.
Setup Script: Licensed under the MIT License.