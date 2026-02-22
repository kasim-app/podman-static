#!/usr/bin/env bash
set -euo pipefail

REPO="kasim-app/podman-static"

echo "Installing host dependencies..."
sudo apt-get update -y
sudo apt-get install -y \
  uidmap passt \
  libgpgme11t64 libseccomp2 libdevmapper1.02.1 libsystemd0

echo "Downloading podman bundle..."
curl -fsSL -o /tmp/podman-bundle.tar.gz \
  "https://github.com/${REPO}/releases/latest/download/podman-bundle-linux-amd64.tar.gz"

echo "Installing podman bundle..."
sudo tar xzf /tmp/podman-bundle.tar.gz -C /usr/local
rm -f /tmp/podman-bundle.tar.gz

# ── Rootless: ensure subordinate UID/GID ranges ──────────
CURRENT_USER="${SUDO_USER:-$(whoami)}"
if ! grep -q "^${CURRENT_USER}:" /etc/subuid 2>/dev/null; then
  echo "Adding subuid/subgid ranges for ${CURRENT_USER}..."
  sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "${CURRENT_USER}"
fi

echo "Verifying..."
podman --version
crun --version
conmon --version

echo "Done. Podman is ready."
