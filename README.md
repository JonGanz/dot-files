# Computer Setup

I'm a developer and I love having access to Linux commands during development. I'm a gamer, I love having games just _work_ without fighting silly Linux issues. I'm also employed, and despite what some may think, a _lot_ of employers (every one I've ever had) uses Windows. Not Mac. Not Linux.

With that in mind, this guide and collection of scripts is intended to setup _my_ computer the way _I_ want it, with a compromise between all the things I need out of it. Our setup: Windows with WSL2.

The general process will be Powershell scripts for setting up what we can on Windows, and Ansible playbooks to setup the WSL2 instance.

## Windows Setup

You will need to run a Powershell terminal as Administrator in order to complete installation. At certain points you will be prompted to setup a WSL user/password, or to restart the computer and run the script again.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
./Setup.ps1
```

## WSL Setup

Enter your WSL instance, either via `wsl ~` or `ubuntu2204.exe`, or simply open a new Ubuntu tab in Windows Terminal. Run the following:

```sh
wget -O setup.sh https://raw.githubusercontent.com/JonGanz/dot-files/refs/heads/master/setup.sh && bash setup.sh
```

# TODO
- [ ] migration to gruvbox
    - [x] the highlight color in the completion menu is unreadable
    - [x] try to change the border color of telescope to be prettier
    - [ ] oh-my-posh theme
    - [ ] Windows Terminal theme
- [ ] make the lualine cleaner and more compact
- [ ] get the stylua.toml file working and picked up
- [ ] fix LazyGit setup when machine has no default folders (Server minimum install for instance); these probably apply to other tools too, LazyGit was just the first to run
    - [ ] ensure the ~/bin folder exists before installing LazyGit
    - [ ] ensure the ~/.config folder exists before installing LazyGit
- [ ] Rust LSP
- [ ] make the Powershell setup a single-command to install Git, pull down the repo, then run the current setup script
- [ ] complete the TODO list in `Setup.ps1`
