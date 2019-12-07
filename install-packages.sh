#!/bin/bash

# Just installs OS packages.

set -e

sudo apt update

# OS package installs
printf "\nInstalling OS packages:\n"
for p in ${PACKAGES[@]}; do echo " --> $p"; done
echo ""
sudo apt install -y ${PACKAGES[@]}
