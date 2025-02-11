#!/usr/bin/env bash
sudo apt update
sudo apt install git software-properties-common
# Using install from Ubuntu Universe since ansible hasn't published for Noble 24.04 yet.
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible-playbook wsl.yml -K
