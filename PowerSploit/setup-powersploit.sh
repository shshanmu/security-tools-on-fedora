i#!/bin/bash

# 1. Configuration
IMAGE_NAME="kali-powersploit"
DOCKERFILE_NAME="Dockerfile.powersploit"

echo "🚀 Starting setup for PowerSploit (Kali-based)..."

# 2. Container Engine Check
if command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
elif command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE="docker"
else
    echo "❌ Error: Neither Podman nor Docker found."
    exit 1
fi

# 3. SELinux Check for Fedora
SELINUX_FLAG=""
if command -v getenforce >/dev/null 2>&1; then
    if [ "$(getenforce)" = "Enforcing" ]; then
        SELINUX_FLAG=":Z"
    fi
fi

# 4. Generate Dockerfile
# Installs powershell and powersploit from Kali repos
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y powershell powersploit && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
# PowerSploit scripts are located in /usr/share/powersploit/
ENTRYPOINT ["pwsh"]
EOF

# 5. Build the Image
echo "📦 Building image: $IMAGE_NAME using $CONTAINER_ENGINE..."
if $CONTAINER_ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .; then
    echo "✅ Image built successfully."
else
    echo "❌ Build failed."
    exit 1
fi

# 6. Define Alias
# Automatically mounts current directory and starts PowerShell
ALIAS_CMD="$CONTAINER_ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" --user \$(id -u):\$(id -g) $IMAGE_NAME"
ALIAS_LINE="alias powersploit-bsd='$ALIAS_CMD'"

# 7. Install Alias
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# PowerSploit Kali Container" >> ~/.bashrc
    echo "$ALIAS_LINE" >> ~/.bashrc
    echo "✅ Alias 'powersploit-bsd' added to ~/.bashrc."
else
    echo "⚠️  Alias already exists."
fi

# 8. Cleanup
rm $DOCKERFILE_NAME
echo "-------------------------------------------------------"
echo "🎉 Setup Complete! Run 'source ~/.bashrc' to activate."
echo "👉 Usage: powersploit-bsd"
echo "👉 Inside pwsh, find modules at: /usr/share/powersploit/"
echo "-------------------------------------------------------"
