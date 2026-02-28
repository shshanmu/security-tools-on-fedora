#!/bin/bash

IMAGE_NAME="kali-wfuzz"
DOCKERFILE_NAME="Dockerfile.wfuzz"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling Wfuzz Toolbox..."
    sed -i '/# --- Wfuzz Tool Start ---/,/# --- Wfuzz Tool End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Alias removed and image deleted."
    exit 0
fi

# 2. Build Image
# We add python3-setuptools to fix the 'pkg_resources' error
# We add curl/ssl dependencies to fix the Pycurl SSL warning
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y \\
    wfuzz \\
    wordlists \\
    seclists \\
    python3-setuptools \\
    python3-pycurl \\
    libcurl4-openssl-dev \\
    && apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT ["wfuzz"]
EOF

echo "📦 Building fixed Wfuzz image..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Alias
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"
WFUZZ_BLOCK="
# --- Wfuzz Tool Start ---
alias wfuzz-bsd='$BASE_CMD'
# --- Wfuzz Tool End ---
"

# 4. Install
if ! grep -q "# --- Wfuzz Tool Start ---" ~/.bashrc; then
    echo "$WFUZZ_BLOCK" >> ~/.bashrc
    echo "✅ Alias 'wfuzz-bsd' added to ~/.bashrc"
else
    echo "⚠️  Alias already exists. Updating image..."
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc && wfuzz-bsd -h"

