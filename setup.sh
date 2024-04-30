#!/usr/bin/env bash
sudo apt update
sudo apt install git software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
mkdir -p ~/setup
git clone https://github.com/JonGanz/dot-files ~/setup

