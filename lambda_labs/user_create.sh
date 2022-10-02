#!/bin/bash
set -euxo pipefail

##
# Config
#

username=nelgau
usershell=/bin/bash
pythonver=3.10.6

##
# Variables
#

userhome="/home/$username"

##
# Pre-fight checks
#

if id "$username" &>/dev/null; then
    echo "User $username already exists."
    exit 1
fi

if [ -d "$userhome" ]; then
    echo "User home directory $userhome already exists."
    exit 1
fi

##
# Create user
#

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

##
# Install Pyenv
#

# Run the bootstrap script
su -l "$username" -c "curl https://pyenv.run | bash"

# Append shell configuration to .bashrc
cat >> "$userhome/.bashrc" <<"END"

# Enable Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
END

# Append shell configuration to .profile
cat >> "$userhome/.profile" <<"END"

# Enable Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
END

# Build recent python and make it the global interpreter
su -l "$username" -c "pyenv install $pythonver"
su -l "$username" -c "pyenv global $pythonver"

# Upgrade pip to the latest version
su -l "$username" -c "pip install --upgrade pip"

##
# Install Poetry
#

## Run the bootstrap script
su -l "$username" -c "curl -sSL https://install.python-poetry.org | python3 -"

# Workaround keyring issue by specifying a null backend
cat >> "$userhome/.bashrc" <<"END"

# Workaround keyring issue https://github.com/python-poetry/poetry/issues/1917
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
END

##
# Install Pipenv
#

# Use pip to install the pipenv package
su -l "$username" -c "pip install pipenv"
