#!/usr/bin/env bash
#
# install-ansible.sh
# Bootstrap Ansible on unregistered RHEL/EL9 or minimal Linux
#
# Usage:
#   sudo bash install-ansible.sh
#   (or run as root)

set -euo pipefail

echo "=== Installing prerequisites ==="

# Ensure basic tools
dnf install -y python3 curl || {
  echo "❌ Failed to install python3/curl. Check your network or dnf repos."
  exit 1
}

# Create a normal non-root environment if possible
USER_HOME="${HOME:-/root}"
export PATH="$USER_HOME/.local/bin:$PATH"

echo "=== Bootstrapping pip ==="
curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python3 /tmp/get-pip.py --user
rm -f /tmp/get-pip.py

echo "=== Installing ansible-core (user space) ==="
python3 -m pip install --user --upgrade pip wheel
python3 -m pip install --user ansible-core

echo "=== Installing community.general collection ==="
"$USER_HOME/.local/bin/ansible-galaxy" collection install community.general --force

echo "=== Adding ~/.local/bin to PATH (if not already) ==="
if ! grep -q ".local/bin" "$USER_HOME/.bashrc"; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> "$USER_HOME/.bashrc"
fi

echo "=== Verifying installation ==="
"$USER_HOME/.local/bin/ansible" --version || true
"$USER_HOME/.local/bin/ansible-playbook" --version || true

echo
echo "✅ Ansible installed successfully."
echo "You may need to reload your shell or run:"
echo "  export PATH=\$HOME/.local/bin:\$PATH"
echo
echo "Now you can run:"
echo "  ansible-playbook awx-install.yml"
