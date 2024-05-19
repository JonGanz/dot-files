# dot-files
My personal configuration files.

## Linux

### Usage

Install Ansible and clone the repo with the following script:

```sh
wget -0 setup.sh https://raw.githubusercontent.com/JonGanz/dot-files/feature/ubuntu-scripts/setup.sh && echo "25ba10dcf22500973a62235bdd5900cc4dd3483a15ff810b69a2871a05e81688 setup.sh" | sha256sum -c - && bash setup.sh
```

Then use Ansible to setup the rest of the system.

```sh
ansible-playbook playbooks/core.yml -K
ansible-playbook playbooks/neovim.yml -K
ansible-playbook playbooks/brave.yml -K
ansible-playbook playbooks/media-apps.yml -K
ansible-playbook playbooks/wezterm.yml -K
ansible-playbook playbooks/personalization.yml
```

Some playbooks have tags. This can be used, for example, to install dependencies for Neovim plugins without wiping and rebuilding Neovim from scratch.

```sh
ansible-playbook playbooks/neovim.yml -K --tags config
ansible-playbook playbooks/wezterm.yml -K --tags config
```

### TODO
- ansible vault
- brave sync key & extensions
- SSH
- git config
- get my aliases back!
- tags and collapse into single playbook
- update playbook to do all updating (apt, flatpak, snap)
- noise suppression for mic (investigate RNNoise)
- sexy wallpaper
- tiled window manager
