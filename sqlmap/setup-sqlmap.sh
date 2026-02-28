#!/bin/bash

IMAGE_NAME="kali-sqlmap"
DOCKERFILE_NAME="Dockerfile.sqlmap"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling sqlmap Toolbox..."
    sed -i '/# --- sqlmap Tool Start ---/,/# --- sqlmap Tool End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Alias removed and image deleted. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
# Installs sqlmap and required python dependencies
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y sqlmap python3-magic && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT ["sqlmap"]
EOF

echo "📦 Building sqlmap image..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Alias
# Maps current dir to /data and also persists sqlmap's own session data
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\""
SQLMAP_BLOCK="
# --- sqlmap Tool Start ---
alias sqlmap-bsd='$BASE_CMD $IMAGE_NAME'
alias sqlmapapi-bsd='$BASE_CMD $IMAGE_NAME sqlmapapi'
# --- sqlmap Tool End ---
"

# 4. Install
if ! grep -q "# --- sqlmap Tool Start ---" ~/.bashrc; then
    echo "$SQLMAP_BLOCK" >> ~/.bashrc
    echo "✅ Alias 'sqlmap-bsd' added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc | Uninstall: $0 --uninstall"
