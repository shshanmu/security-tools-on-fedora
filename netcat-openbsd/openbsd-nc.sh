#!/bin/bash

# 1. Configuration
IMAGE_NAME="kali-nc-bsd"
DOCKERFILE_NAME="Dockerfile.nc_bsd"

echo "🚀 Starting setup for netcat-openbsd (Kali-based)..."

# 2. Generate Dockerfile
# We use WORKDIR /data and the specific nc.openbsd binary
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y netcat-openbsd && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT ["nc.openbsd"]
EOF

# 3. Build the Image
echo "📦 Building Docker image: $IMAGE_NAME..."
if docker build -t $IMAGE_NAME -f $DOCKERFILE_NAME .; then
    echo "✅ Image built successfully."
else
    echo "❌ Docker build failed. Ensure Docker is running."
    exit 1
fi

# 4. Define Aliases
# --network host: allows container to see host interfaces
# -v "\$(pwd):/data": maps current host dir to container workdir
# --user \$(id -u):\$(id -g): ensures created files are owned by you, not root
NC_ALIAS="alias nc-bsd='docker run --rm -it --network host -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) $IMAGE_NAME'"
NETCAT_ALIAS="alias netcat-bsd='docker run --rm -it --network host -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) $IMAGE_NAME'"

# 5. Persistent Installation
echo "🔗 Writing aliases to ~/.bashrc..."
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    {
        echo ""
        echo "# Kali OpenBSD Netcat Container Alias"
        echo "$NC_ALIAS"
        echo "$NETCAT_ALIAS"
    } >> ~/.bashrc
    echo "✅ Aliases appended to ~/.bashrc."
else
    echo "⚠️  Aliases already exist in ~/.bashrc. Skipping."
fi

# 6. Finalize
rm $DOCKERFILE_NAME
echo "-------------------------------------------------------"
echo "🎉 Setup Complete!"
echo "👉 RUN THIS COMMAND TO ACTIVATE: source ~/.bashrc"
echo "👉 TEST WITH: nc-bsd -h"
echo "-------------------------------------------------------"

