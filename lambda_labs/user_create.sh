#!/bin/bash
set -euxo pipefail

username=nelgau
usershell=/bin/bash
userhome="/home/$username"

if id "$username" &>/dev/null; then
    echo "User $username already exists."
    exit 1
fi

if [ -d "$userhome" ]; then
    echo "User home directory $userhome already exists."
    exit 1
fi

# Create the user and home directory
useradd -m -d "$userhome" -s "$usershell" "$username"

# Allow access via SSH
mkdir "/home/$username/.ssh"
cp /home/ubuntu/.ssh/authorized_keys "$userhome/.ssh/authorized_keys"
chown -R "$username:$username" "$userhome/.ssh"
chmod 700 "$userhome/.ssh"
chmod 600 "$userhome/.ssh/authorized_keys"

# Allow passwordless sudo
echo "$username ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$username"
