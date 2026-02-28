i#!/bin/bash

IMAGE_NAME="kali-rubeus"
DOCKERFILE_NAME="Dockerfile.rubeus"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling Rubeus Toolbox..."
    # Deletes everything between these two specific markers
    sed -i '/# --- Rubeus Tool Start ---/,/# --- Rubeus Tool End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Aliases removed and image deleted. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
# We install mono-complete to provide the runtime for the C# binary
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y rubeus mono-complete && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
# The binary is located in /usr/share/windows-resources/rubeus/Rubeus.exe
ENTRYPOINT ["mono", "/usr/share/windows-resources/rubeus/Rubeus.exe"]
EOF

$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Alias
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"
RUBEUS_ALIAS="
# --- Rubeus Tool (Kali Container via Mono) ---
alias rubeus-bsd='$BASE_CMD'
"

# 4. Install
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    echo "$RUBEUS_ALIAS" >> ~/.bashrc
    echo "✅ Alias 'rubeus-bsd' added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc | Uninstall: $0 --uninstall"

