#!/bin/bash

# 1. Configuration
IMAGE_NAME="kali-nc-bsd"
DOCKERFILE_NAME="Dockerfile.nc_bsd"

echo "🚀 Starting setup for netcat-openbsd (Kali-based)..."

# 2. Container Engine Check (Podman vs Docker)
if command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
    echo "🐳 Podman detected as the container engine."
elif command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE="docker"
    echo "🐳 Docker detected as the container engine."
else
    echo "❌ Error: Neither Podman nor Docker found. Please install one to continue."
    exit 1
fi

# 3. SELinux Check (Crucial for Fedora/RHEL)
SELINUX_FLAG=""
if command -v getenforce >/dev/null 2>&1; then
    if [ "$(getenforce)" = "Enforcing" ]; then
        echo "🛡️  SELinux detected as Enforcing. Adding :Z label to volume mounts."
        SELINUX_FLAG=":Z"
    fi
fi

# 4. Generate Dockerfile
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y netcat-openbsd && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT ["nc.openbsd"]
EOF

# 5. Build the Image
echo "📦 Building image: $IMAGE_NAME using $CONTAINER_ENGINE..."
if $CONTAINER_ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .; then
    echo "✅ Image built successfully."
else
    echo "❌ Build failed. Check your container engine status."
    exit 1
fi

# 6. Define Aliases
# --network host: allows container to see host interfaces
# -v "\$(pwd):/data$SELINUX_FLAG": maps current host dir to container workdir
# --user \$(id -u):\$(id -g): ensures created files are owned by you
NC_ALIAS="alias nc-bsd='$CONTAINER_ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" --user \$(id -u):\$(id -g) $IMAGE_NAME'"
NETCAT_ALIAS="alias netcat-bsd='$CONTAINER_ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" --user \$(id -u):\$(id -g) $IMAGE_NAME'"

# 7. Persistent Installation
echo "🔗 Writing aliases to ~/.bashrc..."
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    {
        echo ""
        echo "# Kali OpenBSD Netcat Container Alias ($CONTAINER_ENGINE)"
        echo "$NC_ALIAS"
        echo "$NETCAT_ALIAS"
    } >> ~/.bashrc
    echo "✅ Aliases appended to ~/.bashrc."
else
    echo "⚠️  Aliases already exist in ~/.bashrc. Skipping."
fi

# 8. Finalize
rm $DOCKERFILE_NAME
echo "-------------------------------------------------------"
echo "🎉 Setup Complete (using $CONTAINER_ENGINE)!"
echo "👉 RUN THIS COMMAND TO ACTIVATE: source ~/.bashrc"
echo "👉 TEST WITH: nc-bsd -h"
echo "-------------------------------------------------------"

