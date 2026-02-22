#!/usr/bin/env bash
set -euo pipefail

echo "Removing podman..."
sudo rm -rf /opt/podman
sudo rm -f /etc/profile.d/podman.sh
echo "Done. Log out and back in to clear PATH."
