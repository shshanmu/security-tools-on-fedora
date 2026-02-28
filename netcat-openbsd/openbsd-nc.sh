#!/bin/bash

# 1. Define variables
IMAGE_NAME="kali-nc-bsd"
DOCKERFILE_PATH="./Dockerfile.nc"

echo "🚀 Starting setup for netcat-openbsd (Kali-based) with Volume Support..."

# 2. Create the Dockerfile
cat <<EOF > $DOCKERFILE_PATH
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y netcat-openbsd && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
# Set workdir so relative paths work
WORKDIR /data
ENTRYPOINT ["nc.openbsd"]
EOF

# 3. Build the Docker image
echo "📦 Building Docker image: $IMAGE_NAME..."
docker build -t $IMAGE_NAME -f $DOCKERFILE_PATH .

# 4. Define the aliases with Volume Mapping (-v)
# Maps current directory to /data inside the container
NC_ALIAS="alias nc-bsd='docker run --rm -it --network host -v \"\$(pwd):/data\" $IMAGE_NAME'"
NETCAT_ALIAS="alias netcat-bsd='docker run --rm -it --network host -v \"\$(pwd):/data\" $IMAGE_NAME'"

# 5. Add aliases to .bashrc
echo "🔗 Adding aliases to ~/.bashrc..."
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Netcat OpenBSD (Kali Container with Volume Support)" >> ~/.bashrc
    echo "$NC_ALIAS" >> ~/.bashrc
    echo "$NETCAT_ALIAS" >> ~/.bashrc
    echo "✅ Aliases added successfully."
else
    echo "⚠️  Aliases already exist. Update them manually if you want the volume mount."
fi

# 6. Cleanup
rm $DOCKERFILE_PATH

echo "-------------------------------------------------------"
echo "🎉 Setup Complete!"
echo "👉 Run 'source ~/.bashrc' to activate."
echo "👉 Example: 'nc-bsd -l -p 8080 > received_file.txt'"
echo "-------------------------------------------------------"

