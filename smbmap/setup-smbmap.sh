i#!/bin/bash

IMAGE_NAME="kali-smbmap"
DOCKERFILE_NAME="Dockerfile.smbmap"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling SMBMap Toolbox..."
    sed -i '/# --- SMBMap Tool Start ---/,/# --- SMBMap Tool End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Alias removed and image deleted. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \
    apt-get install -y smbmap python3-cryptography && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT ["smbmap"]
EOF

echo "📦 Building SMBMap image..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Alias
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"
SMBMAP_BLOCK="
# --- SMBMap Tool Start ---
alias smbmap-bsd='$BASE_CMD'
# --- SMBMap Tool End ---
"

# 4. Install
if ! grep -q "# --- SMBMap Tool Start ---" ~/.bashrc; then
    echo "$SMBMAP_BLOCK" >> ~/.bashrc
    echo "✅ Alias 'smbmap-bsd' added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc | Uninstall: $0 --uninstall"

