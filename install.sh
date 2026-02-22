#!/usr/bin/env bash
set -euo pipefail

REPO="kasim-app/podman-static"
PREFIX="/opt/podman"

echo "Installing host dependencies..."
sudo apt-get update -y
sudo apt-get install -y \
  uidmap passt \
  libgpgme11t64 libseccomp2 libdevmapper1.02.1 libsystemd0

echo "Downloading podman bundle..."
curl -fsSL -o /tmp/podman-bundle.tar.gz \
  "https://github.com/${REPO}/releases/latest/download/podman-bundle-linux-amd64.tar.gz"

echo "Installing podman bundle to ${PREFIX}..."
sudo mkdir -p "${PREFIX}"
sudo tar xzf /tmp/podman-bundle.tar.gz -C "${PREFIX}"
rm -f /tmp/podman-bundle.tar.gz

# ── Add to PATH via symlinks ─────────────────────────────
sudo ln -sf "${PREFIX}/bin/podman" /usr/local/bin/podman
sudo ln -sf "${PREFIX}/bin/conmon" /usr/local/bin/conmon
sudo ln -sf "${PREFIX}/bin/crun"   /usr/local/bin/crun

echo "Verifying..."
podman --version
crun --version
conmon --version

echo "Done. Podman is ready."
