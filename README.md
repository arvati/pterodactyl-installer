# :bird: pterodactyl-installer

Unofficial scripts for installing Pterodactyl Panel & Wings. Works with the latest version of Pterodactyl!
Fork from https://github.com/vilhelmprytz/pterodactyl-installer including Oracle Linux 8 Distro

Read more about [Pterodactyl](https://pterodactyl.io/) here. This script is not associated with the official Pterodactyl Project.

## Features

- Automatic installation of the Pterodactyl Panel (dependencies, database, cronjob, nginx).
- Automatic installation of the Pterodactyl Wings (Docker, systemd).
- Panel: (optional) automatic configuration of Let's Encrypt.
- Wings: (optional) compile latest version from source

## Help and support

For help and support regarding the script itself and **not the official Pterodactyl project**, you can join the [Discord Chat](https://pterodactyl-installer.se/discord).

## Supported installations

List of supported installation setups for panel and Wings (installations supported by this installation script).

### Supported panel operating systems and webservers

| Operating System | Version | nginx support      | PHP Version |
| ---------------- | ------- | ------------------ | ----------- |
| Oracle Linux     | 7       | :red_circle:       |             |
|                  | 8       | :white_check_mark: | 8.1         |
|                  | 9       | :white_check_mark: | 8.1         |

### Supported Wings operating systems

| Operating System | Version | Supported          |
| ---------------- | ------- | ------------------ |
| Oracle Linux     | 7       | :red_circle:       |
|                  | 8       | :white_check_mark: |
|                  | 9       | :white_check_mark: |

## Using the installation scripts

To use the installation scripts, simply run this command as root. The script will ask you whether you would like to install just the panel, just the daemon or both.

```bash
bash <(curl -s https://raw.githubusercontent.com/arvati/pterodactyl-installer/master/install.sh)
```

_Note: On some systems, it's required to be already logged in as root before executing the one-line command (where `sudo` is in front of the command does not work)._

Here is a [YouTube video](https://www.youtube.com/watch?v=E8UJhyUFoHM) that illustrates the installation process.

## Let's Encrypt setup

The installation scripts can install and configure Let's Encrypt certificate using acme.sh and cloudflare credentials. If you prefer just use system variables:
* CF_Token
* CF_Account_ID
* CF_Zone_ID

```bash
export CF_Token=''
export CF_Account_ID=''
export CF_Zone_ID=''
```

## Development & Ops

### Creating a release

There are a couple of files that each release commit should always change. Firstly, update the `CHANGELOG.md` so that the release date and release tag are both displayed. No changes should be made to the changelog points themselves. Secondly, update `GITHUB_SOURCE` and `SCRIPT_RELEASE` in both `install-panel.sh` and `install-wings.sh`. Thirdly, update `SCRIPT_RELEASE` in `install.sh`. Finally, you can now push a commit with the message `Release vX.Y.Z`. Create a release on GitHub. See [this commit](https://github.com/vilhelmprytz/pterodactyl-installer/commit/90aaae10785f1032fdf90b216a4a8d8ca64e6d44) for reference.

When the release is published, push another commit which revers the changes you made to `install-wings.sh` and `install-panel.sh`. See [this commit](https://github.com/vilhelmprytz/pterodactyl-installer/commit/be5f361523d1d546d49eef8b3ce1a9145eded234) for reference.

## Contributors ✨

Copyright (C) 2018 - 2021, Vilhelm Prytz, <vilhelm@prytznet.se>

Created and maintained by [Vilhelm Prytz](https://github.com/vilhelmprytz).

Special thanks to the Discord moderators [sam1370](https://github.com/sam1370), [Linux123123](https://github.com/Linux123123) and [sinmineryt](https://github.com/sinmineryt) for helping on the Discord server!
