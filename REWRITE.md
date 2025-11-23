# Rewrite Overview

While I have a fairly clean setup using Ansible, I have some issues with it.

1. Ansible itself requires dependencies in order to run in the first place; dependencies that I myself might not actually want or need.
2. The playbooks are simultaneously tedious to work with, and feel too high-level as though they hide too much of the "nitty-gritty" -- especially given the simplicity of what they are required to perform.
3. It runs pretty slowly for what it does -- it's far too heavy of a system for what I need.

The last point leads me into a great quote I've seen:

> bash is for pets. Ansible is for cattle.

This rings true for me. My own personal desktop, be it for home or work, is mine. It's personal. It's my pet. It's not a black box I manage over an SSH connection. It's the UI I directly interface with. I want to manage it in a more hands-on way; Ansible has a way of making the machine feel ... faceless.

So, time for a redesign. We'll move the Ansible stuff over to a separate repo for managing the home server. :)

## Approach

Let's go bash. It's simple, it's straight-forward, it's supported on all GNU/Linux systems without requiring me to install a bunch of dependencies and setup Ansible.

I have some thoughts as to how this would expand as far as adding complexity in exchange for performance, but let's do this in phases. Waterfall this bitch!

### Phase 1 (current)

The Ansible approach has a single `setup.sh` which installed dependencies in order to pull down the repository and be able to run Ansible. Then you got to run Ansible.

Instead, let's start with a small list of scripts:

`install`, a minimal bash script to pull down the repo and start the setup process.

`setup`, an all-in-one script that runs all the installations, makes necessary modifications to files, and sets up links for configuration files stored in source control.

`configure`, an interactive script that loads a list of needed configuration values from `env.list`, then determines their values and produces `.env` in the setup directory. This will allow us to keep secrets or machine-specific configuration out of repository, and simply be prompted for these values. The `setup` script can run this if the `.env` file is not found, so that the first run will get allnecessary configuration setup.
