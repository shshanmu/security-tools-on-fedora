#!/bin/bash

IMAGE_NAME="kali-mimikatz-suite"
DOCKERFILE_NAME="Dockerfile.mimikatz"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling Mimikatz/Pypykatz Toolbox..."
    sed -i '/# --- Mimikatz Suite Start ---/,/# --- Mimikatz Suite End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Aliases removed and image deleted. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
# Installs original Mimikatz, Wine for execution, and pypykatz via pip
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN dpkg --add-architecture i386 && \\
    apt-get update && \\
    apt-get install -y mimikatz wine wine32 python3 python3-pip python3-venv && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*

# Install pypykatz in a global-accessible way
RUN python3 -m venv /opt/pypykatz && \\
    /opt/pypykatz/bin/pip install pypykatz

WORKDIR /data
EOF

echo "📦 Building Mimikatz Suite (Original + Pypykatz)..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Aliases
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"

MIMIKATZ_BLOCK="
# --- Mimikatz Suite Start ---
alias mimikatz-bsd='$BASE_CMD wine /usr/share/windows-resources/mimikatz/x64/mimikatz.exe'
alias pypykatz-bsd='$BASE_CMD /opt/pypykatz/bin/pypykatz'
# --- Mimikatz Suite End ---
"

# 4. Install
if ! grep -q "# --- Mimikatz Suite Start ---" ~/.bashrc; then
    echo "$MIMIKATZ_BLOCK" >> ~/.bashrc
    echo "✅ Aliases added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc"
echo "👉 Original: mimikatz-bsd"
echo "👉 Python: pypykatz-bsd"
if ! grep -q "# --- Mimikatz Tool Start ---" ~/.bashrc; then
    echo "$MIMIKATZ_BLOCK" >> ~/.bashrc
    echo "✅ Alias 'mimikatz-bsd' added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc | Uninstall: $0 --uninstall"
