#!/bin/bash
set -euxo pipefail

username=nelgau

# Remove passwordless sudo privileges
rm "/etc/sudoers.d/$username"

# Terminate all running processes
killall -9 --wait --quiet --user "$username" || true

# Delete the user and home directory
userdel --remove --force "$username"
