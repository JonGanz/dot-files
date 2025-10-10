#!/usr/bin/env bash

sudo apt update
sudo apt install git software-properties-common

# Using install from Ubuntu Universe since ansible hasn't published for Noble 24.04 yet.
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

mkdir -p ~/setup
git clone https://github.com/JonGanz/dot-files ~/setup --recurse-submodules
cd ~/setup
git checkout feature/windows-setup

# TODO: Prompt for the Vault password, dump in vault.cred

# Commenting out the auto-run for now since we haven't pulled in the vault credentials yet.
#ansible-playbook wsl.yml -K

git remote set-url origin git@github.com:JonGanz/dot-files.git

