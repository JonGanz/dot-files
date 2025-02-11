# dot-files
My personal configuration files.

## Linux

### Usage

Install Ansible and clone the repo with the following script:

```sh
wget -O setup.sh https://raw.githubusercontent.com/JonGanz/dot-files/feature/ubuntu-scripts/setup.sh && echo "25ba10dcf22500973a62235bdd5900cc4dd3483a15ff810b69a2871a05e81688 setup.sh" | sha256sum -c - && bash setup.sh
```

Secrets are encrypted with Ansible Vault. You can either opt to enter the credentials at the command prompt, or choose to add the password to a file. Enter the password as a single line in the file `vault.cred`. You could manually provide `--vault-password-file vault.cred` whenever calling `ansible-playbook`, but instead this has been configured in `ansible.cfg`.

Then use Ansible to setup the rest of the system.

```sh
ansible-playbook playbooks/core.yml -K
ansible-playbook playbooks/ssh.yml
ansible-playbook playbooks/neovim.yml -K
ansible-playbook playbooks/brave.yml -K
ansible-playbook playbooks/media-apps.yml -K
ansible-playbook playbooks/wezterm.yml -K
ansible-playbook playbooks/personalization.yml
ansible-playbook playbooks/syncthing.yml -K
```

Some playbooks have tags. This can be used, for example, to install dependencies for Neovim plugins without wiping and rebuilding Neovim from scratch.

```sh
ansible-playbook playbooks/neovim.yml -K --tags config
ansible-playbook playbooks/wezterm.yml -K --tags config
```

### TODO
- Obsidian
- git config
- get my aliases back!
- replace the docker.io package with the real one
- once the SSH key has been added, we could replace `origin` with the proper SSH protocol so that we can push changes back up
- tiled window manager
- tags and collapse into single playbook
- update playbook to do all updating (apt, flatpak, snap)
- noise suppression for mic (investigate RNNoise)
