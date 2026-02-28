#!/bin/bash

IMAGE_NAME="kali-powersploit"
DOCKERFILE_NAME="Dockerfile.powersploit"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling PowerSploit Toolbox..."
    sed -i "/# --- PowerSploit Core/,/alias powersploit-bsd/d" ~/.bashrc
    $ENGINE rmi $IMAGE_NAME
    echo "✅ Aliases removed and image deleted. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Dockerfile
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && apt-get install -y powershell powersploit && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV HOME=/tmp
WORKDIR /data

# Loader script that sources everything
RUN echo '\$ps = "/usr/share/windows-resources/powersploit"' > /load_modules.ps1 && \\
    echo 'Write-Host "🔍 Force-Loading Modules..." -ForegroundColor Yellow' >> /load_modules.ps1 && \\
    echo '. "\$ps/Recon/PowerView.ps1"' >> /load_modules.ps1 && \\
    echo '. "\$ps/Privesc/PowerUp.ps1"' >> /load_modules.ps1 && \\
    echo '. "\$ps/Exfiltration/Invoke-Mimikatz.ps1"' >> /load_modules.ps1 && \\
    echo 'Write-Host "✅ PowerView, PowerUp, & Mimikatz Loaded!" -ForegroundColor Green' >> /load_modules.ps1

# FIX: Start pwsh and DOT-SOURCE the loader into the primary session scope
ENTRYPOINT ["pwsh", "-NoLogo", "-NoExit", "-Command", ". /load_modules.ps1"]
EOF

# 3. Build and Alias
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .
ALIAS_LINE="alias powersploit-bsd='$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME'"

if ! grep -q "$IMAGE_NAME" ~/.bashrc; then
    echo "$ALIAS_LINE" >> ~/.bashrc
    echo "✅ Alias 'powersploit-bsd' added."
fi

rm $DOCKERFILE_NAME
echo "🚀 Run: source ~/.bashrc && powersploit-bsd"

