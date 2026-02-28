#!/bin/bash

IMAGE_NAME="kali-kerberoast"
DOCKERFILE_NAME="Dockerfile.kerberoast"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- FIXED UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling Kerberoast Toolbox..."
    sed -i '/# --- Kerberoast Tool Start ---/,/# --- Kerberoast Tool End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Aliases removed and image deleted. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y kerberoast python3-pyasn1 python3-scapy && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
EOF

echo "📦 Building Kerberoast image..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Prefixed Aliases
# Kali stores these in /usr/share/kerberoast/
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"
SCRIPTS=("tgsrepcrack.py" "kirbi2john.py" "kerberoast.py" "extracttgsrepfrompcap.py" "krbroast-pcap2hashcat.py")

{
    echo "# --- Kerberoast Tool Start ---"
    for script in "${SCRIPTS[@]}"; do
        # Extract name without .py, then add prefix and suffix
        # Example: alias kerberoast-tgsrepcrack-bsd='...'
        CMD_NAME=$(echo "$script" | sed 's/\.py//')
        echo "alias kerberoast-$CMD_NAME-bsd='$BASE_CMD python3 /usr/share/kerberoast/$script'"
    done
    echo "# --- Kerberoast Tool End ---"
} > kerberoast_aliases.tmp

# 4. Install
if ! grep -q "# --- Kerberoast Tool Start ---" ~/.bashrc; then
    echo "" >> ~/.bashrc
    cat kerberoast_aliases.tmp >> ~/.bashrc
    echo "✅ Prefixed aliases added to ~/.bashrc"
else
    echo "⚠️  Aliases already exist. Run '$0 --uninstall' first to refresh."
fi

rm $DOCKERFILE_NAME kerberoast_aliases.tmp
echo "-------------------------------------------------------"
echo "🎉 Setup Complete! Run: source ~/.bashrc"
echo "👉 Try typing 'kerberoast-' and hitting Tab to see tools."
echo "-------------------------------------------------------"

