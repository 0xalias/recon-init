#!/bin/bash

# One time OS setup for reconaissance.

set -e

# check for args
usage() {
    echo ""
    echo "Usage: init.sh [GH_TOKEN]"
    echo ""
    exit 1
}

if [[ -z "$1" ]]; then
    usage
fi

DT="$(date +%Y%m%d%H%M%S)"

# OS Variables
OS_USER="alias"
OS_USER_HOME="/home/$OS_USER"
PVT_KEY_PATH="$OS_USER_HOME/.ssh/id_rsa"
PUB_KEY_PATH="${PVT_KEY_PATH}.pub"
EMAIL="x@0xalias.com"
PACKAGES=$(cat packages)

# GH variables
GH_USER="0xalias"
GH_KEYS_API_ENDPOINT="https://api.github.com/user/keys"
GH_KEY_NAME="${GH_USER}-${DT}"
GH_TOKEN="$1"

printf "\nStarting setup...\n\n"

# OS update
printf "\nUpdating the OS packages\n"
apt update
apt upgrade -y

# OS package installs
printf "\nInstalling OS packages:\n"
for p in ${PACKAGES[@]}; do echo " --> $p"; done
echo ""
apt install -y ${PACKAGES[@]}

# add user
printf "\nAdding %s user\n" $OS_USER
adduser --home $OS_USER_HOME --disabled-password --gecos "" $OS_USER

# add .ssh dir
mkdir $OS_USER_HOME/.ssh
chmod 700 $OS_USER_HOME/.ssh

# add user to sudoers
printf "\nAdding %s user to sudoers\n" $OS_USER
usermod -aG sudo $OS_USER

# don't prompt for a password when using sudo
echo "$OS_USER ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$OS_USER
touch "$OS_USER_HOME/.sudo_as_admin_successful"

# create new ssh key
printf "\nCreating SSH key\n"
ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f $PVT_KEY_PATH -q -N ''
chmod 600 $PVT_KEY_PATH
chmod 644 $PUB_KEY_PATH
chown -R $OS_USER:$OS_USER $OS_USER_HOME

# push new public ssh key to GH
printf "\nPushing SSH key to GH\n"
KEY_CONTENTS=$(cat $PUB_KEY_PATH)
curl -vvv -u "${GH_USER}:${GH_TOKEN}" -d "{\"title\":\"${GH_KEY_NAME}\",\"key\":\"${KEY_CONTENTS}\"}" $GH_KEYS_API_ENDPOINT

# configure git
su - $OS_USER
git config --global user.email "$EMAIL"
git config --global user.name "$OS_USER"
