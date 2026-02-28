i#!/bin/bash

IMAGE_NAME="kali-impacket"
DOCKERFILE_NAME="Dockerfile.impacket"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling Impacket Toolbox..."
    
    # This deletes everything between the two specific markers we placed
    if grep -q "# --- Impacket Framework Toolbox" ~/.bashrc; then
        sed -i '/# --- Impacket Framework Toolbox/,/# --- End Impacket ---/d' ~/.bashrc
        echo "✅ Aliases removed from ~/.bashrc"
    else
        echo "⚠️  No Impacket alias block found in ~/.bashrc"
    fi
    
    # Remove the image
    if $ENGINE image inspect $IMAGE_NAME >/dev/null 2>&1; then
        $ENGINE rmi $IMAGE_NAME
        echo "✅ Image $IMAGE_NAME deleted."
    fi
    
    echo "👉 Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y impacket-scripts python3-impacket && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
EOF

echo "📦 Building image: $IMAGE_NAME..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Dynamic Alias Generation
# We run the container once to list all impacket-* binaries in /usr/bin
echo "🔗 Extracting full tool list and generating aliases..."
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"
TOOL_LIST=$($ENGINE run --rm $IMAGE_NAME ls /usr/bin | grep '^impacket-')

{
    echo ""
    echo "# --- Impacket Framework Toolbox (Kali Container) ---"
    for tool in $TOOL_LIST; do
        # Example: alias impacket-psexec-bsd='...'
        echo "alias $tool-bsd='$BASE_CMD $tool'"
    done
    echo "# --- End Impacket ---"
} > impacket_aliases.txt

# 4. Install to .bashrc
if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    cat impacket_aliases.txt >> ~/.bashrc
    echo "✅ $(wc -l < impacket_aliases.txt | awk '{print $1-3}') aliases added to ~/.bashrc"
else
    echo "⚠️  Aliases already exist. Use $0 --uninstall to reset."
fi

rm $DOCKERFILE_NAME impacket_aliases.txt
echo "-------------------------------------------------------"
echo "🎉 Setup Complete! Run: source ~/.bashrc"
echo "👉 Use 'impacket-secretsdump-bsd' or 'impacket-psexec-bsd' etc."
echo "👉 Total tools indexed: $(echo $TOOL_LIST | wc -w)"
echo "-------------------------------------------------------"
