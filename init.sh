#!/bin/bash

# One time OS setup for recon.

set -e

# source variables
source common.sh

printf "\nStarting setup...\n\n"

# OS update
printf "\nUpdating the OS\n"
apt update
apt upgrade -y

# OS package installs
printf "\nInstalling OS packages:\n"
for p in "${PACKAGES[@]}"; do echo " --> $p"; done
echo ""
apt install -y ${PACKAGES[@]}

# add user
printf "\nAdding $USER user\n"
useradd -m -s $SH $USER

# add user to sudoers
printf "\nAdding $USER user to sudoers\n"
usermod -aG sudo $USER

# don't prompt for password when using sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$USER
touch $USER_HOME/.sudo_as_admin_successful

