#!/bin/bash

IMAGE_NAME="kali-msf-toolbox"
DOCKERFILE_NAME="Dockerfile.msf_toolbox"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling Metasploit Toolbox..."
    
    # Remove the block of aliases from .bashrc
    sed -i "/# --- Metasploit Framework Toolbox/,/msf-pdf2xdp-bsd/d" ~/.bashrc
    
    # Remove the Docker/Podman image
    $ENGINE rmi $IMAGE_NAME
    
    echo "✅ Aliases removed from ~/.bashrc and image deleted."
    echo "👉 Run 'source ~/.bashrc' to finalize."
    exit 0
fi
# -----------------------

# 2. Generate Dockerfile
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && apt-get install -y metasploit-framework postgresql iproute2 fzf && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a launcher script inside the container to handle IP selection
RUN echo '#!/bin/bash' > /msf_launcher.sh && \\
    echo 'service postgresql start >/dev/null && msfdb init >/dev/null 2>&1' >> /msf_launcher.sh && \\
    echo 'echo "🌐 Detectable IPs on Host:"' >> /msf_launcher.sh && \\
    echo 'ips=(\$(ip -4 -o addr show | awk "{print \\\$4}" | cut -d/ -f1))' >> /msf_launcher.sh && \\
    echo 'for i in "\${!ips[@]}"; do echo "\$i) \${ips[\$i]}"; done' >> /msf_launcher.sh && \\
    echo 'read -p "👉 Select Index (default 0): " idx' >> /msf_launcher.sh && \\
    echo 'SELECTED_IP=\${ips[\${idx:-0}]}' >> /msf_launcher.sh && \\
    echo 'msfconsole -q -x "setg LHOST \$SELECTED_IP; echo OK: LHOST set to \$SELECTED_IP"' >> /msf_launcher.sh && \\
    chmod +x /msf_launcher.sh

WORKDIR /data
EOF

# 3. Build the Image
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 4. Define ALL Aliases
# Using the dynamic $BASE_CMD ensures portability and SELinux support
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"

MSF_ALIASES="
# --- Metasploit Framework Toolbox (Kali Container) ---
alias msfconsole-bsd='$BASE_CMD /msf_launcher.sh'
alias msfvenom-bsd='$BASE_CMD msfvenom'
alias msfdb-bsd='$BASE_CMD msfdb'
alias msfrpc-bsd='$BASE_CMD msfrpc'
alias msfrpcd-bsd='$BASE_CMD msfrpcd'
alias msfd-bsd='$BASE_CMD msfd'
alias msf-virustotal-bsd='$BASE_CMD msf-virustotal'
alias msf-egghunter-bsd='$BASE_CMD msf-egghunter'
alias msf-exe2vba-bsd='$BASE_CMD msf-exe2vba'
alias msf-exe2vbs-bsd='$BASE_CMD msf-exe2vbs'
alias msf-find_badchars-bsd='$BASE_CMD msf-find_badchars'
alias msf-halflm_second-bsd='$BASE_CMD msf-halflm_second'
alias msf-hmac_sha1_crack-bsd='$BASE_CMD msf-hmac_sha1_crack'
alias msf-java_deserializer-bsd='$BASE_CMD msf-java_deserializer'
alias msf-jsobfu-bsd='$BASE_CMD msf-java_jsobfu'
alias msf-md5_lookup-bsd='$BASE_CMD msf-md5_lookup'
alias msf-metasm_shell-bsd='$BASE_CMD msf-metasm_shell'
alias msf-msf_irb_shell-bsd='$BASE_CMD msf-msf_irb_shell'
alias msf-nasm_shell-bsd='$BASE_CMD msf-msf_nasm_shell'
alias msf-pattern_create-bsd='$BASE_CMD msf-pattern_create'
alias msf-pdf2xdp-bsd='$BASE_CMD msf-pdf2xdp'
alias msf-nasl-bsd='$BASE_CMD msf-nasl'
alias msf-nmap-bsd='$BASE_CMD db_nmap'
"

# 5. Install to .bashrc
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    echo "$MSF_ALIASES" >> ~/.bashrc
    echo "✅ All 23 Metasploit aliases added to ~/.bashrc"
else
    echo "⚠️  Aliases already exist in ~/.bashrc. Please check/update manually."
fi

# 6. Cleanup
rm $DOCKERFILE_NAME
echo "-------------------------------------------------------"
echo "🎉 Setup Complete! Run: source ~/.bashrc"
echo "👉 Use 'msfconsole-bsd' to start the console with IP selection."
echo "👉 Use 'msfvenom-bsd' to generate payloads."
echo "🗑️  To uninstall later, run: $0 --uninstall"
echo "-------------------------------------------------------"

