# Computer Setup

I'm a developer and I love having access to Linux commands during development. I'm a gamer, I love having games just _work_ without fighting silly Linux issues. I'm also employed, and despite what some may think, a _lot_ of employers (every one I've ever had) uses Windows. Not Mac. Not Linux.

With that in mind, this guide and collection of scripts is intended to setup _my_ computer the way _I_ want it, with a compromise between all the things I need out of it. Our setup: Windows with WSL2.

The general process will be Powershell scripts for setting up what we can on Windows, and Ansible playbooks to setup the WSL2 instance.

## Windows Setup

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
./Setup.ps1
```

## WSL Setup

Enter your WSL instance, either via `wsl ~` or `ubuntu2204.exe`, or simply open a new Ubuntu tab in Windows Terminal. Run the following:

```sh
wget -O setup.sh https://raw.githubusercontent.com/JonGanz/dot-files/feature/windows-setup/setup.sh && bash setup.sh
```
