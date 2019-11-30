#!/bin/bash

set -e

USER=$(cat user)
USER_HOME="/home/$USER"
BASHRC="$USER_HOME/.bashrc"

PACKAGES=$(cat packages)
INSTALLERS_DIR="installers"
INSTALLER_SCRIPTS=$(cat installer-scripts)
DIRS=$(cat dirs)


function mkdir_if_not_present() {
    [ ! -d "$1" ] && mkdir $1 && echo "$1 created"
}

function append_if_not_present() {
    echo "appending $1 to $2"
    grep -q -F '$1' $2 || echo '$1' >> $2
}

function bashrc_add() {
    append_if_not_present $1 $BASHRC
}

function copy_to_user() {
    echo "copying $1 to $USER_HOME/$1"
    cp -rf $1 $USER_HOME/
    chown -R $USER:$USER $USER_HOME/$1
}
