#!/usr/bin/env bash
set -euo pipefail

echo "Removing systemd socket activation..."
systemctl --user disable --now podman.socket podman.service 2>/dev/null || true
rm -f ~/.config/systemd/user/podman.socket
rm -f ~/.config/systemd/user/podman.service
systemctl --user daemon-reload

echo "Removing podman..."
sudo rm -rf /opt/podman
sudo rm -f /etc/profile.d/podman.sh
echo "Done. Log out and back in to clear PATH."
