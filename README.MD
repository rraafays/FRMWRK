# FRMWRK

This repository, `FRMWRK`, contains my Framework 13 NixOS system configuration.
The configuration is modular and designed for a single non-root user to maintain and use.

## Features

- **Modular Configuration**: uses git submodules stored under `./modules/`
- **Rootless Editing**: designed for cloning, modification & maintenance by a non-root user

## Installation & Setup

### 1. clone the repository

Start by cloning the repository into your home directory:

```bash
git clone --recurse-submodules https://github.com/yourusername/FRMWRK.git ~/FRMWRK
```

### 2. create the symlink

Next, create a symlink from the cloned repository to `/etc/nixos/FRMWRK`

```bash
sudo ln -s ~/FRMWRK /etc/nixos/FRMWRK
```

### 3. modify `configuration.nix`

You will need to modify the existing configuration.nix located in `/etc/nixos/`, 
to import the new configuration:

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./FRMWRK/configuration.nix
    ];

  # ... other configurations
}
```

### 4. apply the configuration

Finally, apply the configuration

```bash
sudo nixos-rebuild switch
```

## Managing Git Submodules

The repository uses Git submodules to manage external configurations and dependencies.
Below are some common operations for managing these submodules.

### 1. cloning modules

If you haven't already cloned the repository with submodules, you can initialise
and update them after cloning:

```bash
git submodule update --init --recursive
```

### 2. updating modules

To update all submodules to the latest commit on their respective branches:

```bash
git submodule update --remote --merge
```

### 3. adding modules

If you need to add a new module:

```bash
git submodule add <repository_url> modules/<module_name>
```

### 4. removing modules

To remove a module:

1. remove the relevant line from `.gitmodules`
2. remove the module's entry in .git/config
3. delete the module's directory
4. run `git rm --cached` on the submodule directory 
