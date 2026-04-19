#!/usr/bin/env bash
set -euo pipefail

REPO="kasim-app/podman-static"
PREFIX="/opt/podman"
PROFILE="/etc/profile.d/podman.sh"

echo "Installing host dependencies..."
sudo apt-get update -y
sudo apt-get install -y \
uidmap passt slirp4netns fuse-overlayfs \
libgpgme11t64 libseccomp2 libdevmapper1.02.1 libsystemd0 \
libglib2.0-0 libgpg-error0 libassuan0 libprotobuf-c1 libprotobuf32t64

echo "Downloading podman bundle..."
curl -fsSL -o /tmp/podman-bundle.tar.gz \
"https://github.com/${REPO}/releases/latest/download/podman-bundle-linux-amd64.tar.gz"

echo "Installing to ${PREFIX}..."
sudo rm -rf "${PREFIX}"
sudo mkdir -p "${PREFIX}"
sudo tar xzf /tmp/podman-bundle.tar.gz -C "${PREFIX}"
rm -f /tmp/podman-bundle.tar.gz

# Add to PATH and point podman at bundled config
printf 'export PATH="/opt/podman/bin:$PATH"\nexport CONTAINERS_CONF="/opt/podman/etc/containers/containers.conf"\n' \
| sudo tee "${PROFILE}" > /dev/null

# Install quadlet as a user systemd generator so .container files work
GENERATOR_DIR="/usr/lib/systemd/user-generators"
sudo mkdir -p "${GENERATOR_DIR}"
sudo ln -sf "${PREFIX}/libexec/podman/quadlet" "${GENERATOR_DIR}/podman-user-generator"

echo "Verifying (using new shell env)..."
export PATH="${PREFIX}/bin:$PATH"
podman --version
podman info 2>&1 | grep -A2 'ociRuntime'

echo "Setting up systemd socket activation..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/podman.socket << 'EOF'
[Unit]
Description=Podman API Socket
Documentation=man:podman-system-service(1)

[Socket]
ListenStream=%t/podman/podman.sock
SocketMode=0660

[Install]
WantedBy=sockets.target
EOF

cat > ~/.config/systemd/user/podman.service << 'EOF'
[Unit]
Description=Podman API Service
Requires=podman.socket
After=podman.socket
Documentation=man:podman-system-service(1)
StartLimitIntervalSec=0

[Service]
Delegate=true
Type=exec
KillMode=process
Environment=LOGGING="--log-level=info"
Environment=CONTAINERS_CONF=/opt/podman/etc/containers/containers.conf
ExecStart=/opt/podman/bin/podman $LOGGING system service

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now podman.socket
loginctl enable-linger "$USER"
echo "Podman socket active at /run/user/$(id -u)/podman/podman.sock"

echo "Done. Log out and back in (or run: source ${PROFILE})"
