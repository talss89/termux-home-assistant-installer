# termux-home-assistant-installer

A script to provision Home Assistant Core on an Android / Termux device. This is not officially supported.

**Warning: This is pre-release quality, if this breaks your Termux installation, I am not responsible. Please try this on a fresh Termux installation that you're happy to dispose of if required.**

## Quick Installer

```bash
curl -s https://github.com/talss89/termux-home-assistant-installer/releases/download/v2023.4.4-alpha.2/remote-install.sh | bash
```

Please be patient, this will take a while depending on your device specifications.

## What this script does

- Updates packages, and installs dependencies
- Downgrades `ffmpeg` to 5.1.2-7 for `ha-av` compatibility
- Creates a virtualenv in `~/hass`. **Please ensure this directory does not exist before installing**
- Builds `pip` dependencies such as `numpy` etc.
- Installs Home Assistant Core in your `~/hass` directory

## Starting `hass` after installation

1. Start from your home dir: `cd ~`
1. `source hass/bin/activate`
1. `hass -v`
1. Wait, again, for lazy dependencies to be installed (first boot only)
