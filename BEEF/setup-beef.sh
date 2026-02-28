#!/bin/bash

IMAGE_NAME="kali-beef"
DOCKERFILE_NAME="Dockerfile.beef"
BEEF_USER="admin"
BEEF_PASS="ChangeMe123!"

# 1. Engine & SELinux Check
if command -v podman >/dev/null 2>&1; then ENGINE="podman"; else ENGINE="docker"; fi
SELINUX_FLAG=""; if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then SELINUX_FLAG=":Z"; fi

# --- UNINSTALL LOGIC ---
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Uninstalling BeEF Toolbox..."
    sed -i '/# --- BeEF Start ---/,/# --- BeEF End ---/d' ~/.bashrc
    $ENGINE rmi $IMAGE_NAME 2>/dev/null
    exit 0
fi

# 2. Build Image with Force-Load environment
cat <<EOF > $DOCKERFILE_NAME
FROM kalilinux/kali-rolling

# Install beef-xss and build dependencies
RUN apt-get update && \\
    apt-get install -y beef-xss ruby-bundler ruby-dev build-essential \\
    libsqlite3-dev libssl-dev zlib1g-dev libyaml-dev libxml2-dev \\
    python3 curl && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share/beef-xss

# FIX: Reconstruct the entire Ruby environment
# 1. Manually install failing gems (eventmachine, msgpack, sqlite3, thin)
# 2. Generate a new lockfile
# 3. Use 'bundle exec' to ensure all gems are loaded correctly
RUN rm -f Gemfile.lock && \\
    gem install eventmachine msgpack sqlite3 thin --no-document && \\
    bundle config unset frozen && \\
    bundle lock && \\
    bundle install

# Pre-configure credentials
RUN sed -i "s/user: \"beef\"/user: \"$BEEF_USER\"/" /etc/beef-xss/config.yaml && \\
    sed -i "s/passwd: \"beef\"/passwd: \"$BEEF_PASS\"/" /etc/beef-xss/config.yaml

# Fix for Thin/EventMachine permission issues in containers
RUN mkdir -p /usr/share/beef-xss/db

# Use 'bundle exec' to run BeEF within the reconstructed environment
ENTRYPOINT ["bundle", "exec", "ruby", "beef"]
EOF

echo "📦 Rebuilding BeEF image with 'bundle exec' support..."
$ENGINE build -t $IMAGE_NAME -f $DOCKERFILE_NAME .

# 3. Define Alias
BASE_CMD="$ENGINE run --rm -it --network host -v \"\$(pwd):/data$SELINUX_FLAG\" $IMAGE_NAME"
BEEF_BLOCK="
# --- BeEF Start ---
alias beef-bsd='$BASE_CMD'
# --- BeEF End ---
"

# 4. Install
if ! grep -q "# --- BeEF Start ---" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "$BEEF_BLOCK" >> ~/.bashrc
    echo "✅ Alias 'beef-bsd' added to ~/.bashrc"
fi

rm $DOCKERFILE_NAME
echo "-------------------------------------------------------"
echo "🎉 Setup Complete! Run: source ~/.bashrc"
echo "👉 Launch with: beef-bsd"
echo "-------------------------------------------------------"

