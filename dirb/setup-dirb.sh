i#!/bin/bash

IMAGE_NAME="kali-dirb-suite"
DOCKERFILE_NAME="Dockerfile.dirb_suite"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling DIRB/DirBuster Toolbox..."
    sed -i '/# --- Web Discovery Start ---/,/# --- Web Discovery End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    echo "✅ Aliases removed. Run 'source ~/.bashrc' to finalize."
    exit 0
fi

# 2. Build Image
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling
RUN apt-get update && \\
    apt-get install -y dirb dirbuster seclists wordlists \\
    dbus-x11 libxext6 libxrender1 libxtst6 libxi6 \\
    && apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
WORKDIR /data
EOF

echo "📦 Building Web Discovery Suite..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Dynamic GUI Flags (Wayland vs X11)
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    GUI_FLAGS="-e DISPLAY=\$DISPLAY -e WAYLAND_DISPLAY=\$WAYLAND_DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro"
else
    GUI_FLAGS="-e DISPLAY=\$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro"
fi

# 4. Define Aliases
# Note: dirbuster-bsd now runs 'xhost' automatically before the container
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\""
SEC_FLAGS="--security-opt label=type:container_runtime_t"

DIRB_BLOCK="
# --- Web Discovery Start ---
alias dirb-bsd='$BASE_CMD $IMAGE_NAME dirb'
alias dirb-gendict-bsd='$BASE_CMD $IMAGE_NAME dirb-gendict'
alias dirb-html2dic-bsd='$BASE_CMD $IMAGE_NAME html2dic'
alias dirbuster-bsd='xhost +local:\$(whoami) > /dev/null && $BASE_CMD $SEC_FLAGS $GUI_FLAGS $IMAGE_NAME dirbuster'
# --- Web Discovery End ---
"

# 5. Install to .bashrc
if ! grep -q "# --- Web Discovery Start ---" ~/.bashrc; then
    echo "$DIRB_BLOCK" >> ~/.bashrc
    echo "✅ Aliases added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "-------------------------------------------------------"
echo "🎉 Setup Complete! Run: source ~/.bashrc"
echo "👉 Simply run 'dirbuster-bsd' to launch the GUI."
echo "-------------------------------------------------------"

