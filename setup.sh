#!/usr/bin/env bash
sudo apt update
sudo apt install git software-properties-common
# Using install from Ubuntu Universe since ansible hasn't published for Noble 24.04 yet.
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# TODO: Checkout the repository at ~/setup
# TODO: Prompt for the Vault password, dump in vault.cred

ansible-playbook wsl.yml -K

# TODO: Update the Repo URL (which assumes the playbook correctly installed the SSH keys)

