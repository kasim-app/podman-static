#!/usr/bin/env bash
set -euo pipefail

echo "Installing host dependencies..."
sudo apt-get update -y
sudo apt-get install -y uidmap passt

echo "Downloading podman bundle..."
curl -fsSL -o /tmp/podman-bundle.tar.gz \
  "https://github.com/kasim-app/podman-static/releases/latest/download/podman-bundle-linux-amd64.tar.gz"

echo "Installing podman bundle..."
sudo tar xzf /tmp/podman-bundle.tar.gz -C /usr/local
rm -f /tmp/podman-bundle.tar.gz

# Ensure config dir exists and doesn't conflict with apt-installed defaults
sudo mkdir -p /etc/containers
[ -f /etc/containers/policy.json ] || \
  sudo cp /usr/local/etc/containers/policy.json /etc/containers/policy.json
[ -f /etc/containers/storage.conf ] || \
  sudo cp /usr/local/etc/containers/storage.conf /etc/containers/storage.conf
[ -f /etc/containers/registries.conf ] || \
  sudo cp /usr/local/etc/containers/registries.conf /etc/containers/registries.conf

# Tell podman where to find helper binaries
sudo mkdir -p /etc/containers/containers.conf.d
cat <<'EOF' | sudo tee /etc/containers/containers.conf.d/helper-path.conf >/dev/null
[engine]
helper_binaries_dir = ["/usr/local/libexec/podman"]
EOF

echo "Verifying..."
podman --version
crun --version
conmon --version

echo "Done. Podman is ready."
