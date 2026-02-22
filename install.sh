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

# Add to PATH (prepend so bundled bins take priority)
echo 'export PATH="/opt/podman/bin:$PATH"' | sudo tee "${PROFILE}" > /dev/null

echo "Verifying (using new shell env)..."
export PATH="${PREFIX}/bin:$PATH"
podman --version
podman info 2>&1 | grep -A2 'ociRuntime'

echo "Done. Log out and back in (or run: source ${PROFILE})"
