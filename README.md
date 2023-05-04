# termux-home-assistant-installer

A script to provision Home Assistant Core on an Android / Termux device. This is not officially supported.

**Warning: This is pre-release quality, if this breaks your Termux installation, I am not responsible. Please try this on a fresh Termux installation that you're happy to dispose of if required.**

**Note: This package currently supports `aarch64` devices only. If another architecture is important to you, please raise an issue and I will look into supporting.**

## Quick Installer

```bash
curl -sL https://github.com/talss89/termux-home-assistant-installer/releases/download/v2023.4.4-alpha.3/remote-install.sh | bash
```

Please be patient, this will take a while depending on your device specifications.

## What this script does

- Updates packages, and installs dependencies
- Downgrades `ffmpeg` to 5.1.2-7 for `ha-av` compatibility
- Creates a virtualenv in `~/hass`. **Please ensure this directory does not exist before installing**
- Downgrades `python-numpy` to 1.23.2
- Installs Home Assistant Core in your `~/hass` directory

## Starting `hass` after installation

1. Start from your home dir: `cd ~`
1. `source hass/bin/activate`
1. `hass -v`
1. Wait, again, for lazy dependencies to be installed (first boot only)

If you run into an error, please CTRL+C and re-run `hass -v`. There are some intermittent install issues with file-locking I believe.

## Got Root?

Home Assistant on Android / Termux works best when you have a rooted device, and run with `sudo`.

That said, I've had success installing on a factory spec Samsung S21 FE without root. You will notice some `CRITICAL` messages in the log output referring to `/proc` endpoints not being found. These can be ignored for the most part.

Remember that running `sudo hass -v` and `hass -v` will result in Home Assistant looking for a configuration file in `~/.suroot/.homeassistant` and `~/.homeassistant` respectively. This can be confusing when you forget to add `sudo`, and it looks like your HA has been wiped. I have had success creating a symlink between these directories to keep both inline. Just be aware that if the HA backup process sees a symlink, the `tar` archive can be difficult to extract / corrupt.

## Why is this hard?

The first thing to mention is that Termux isn't Linux. Packages that should just build on Linux fail to build in Termux. One of these packages is `numpy`, which Home Assistant relies on.

Packages in `termux-packages` use a very clever cross-compilation system, but the repo only contains the latest version of packages. In order to install outdated specific versions of Termux packages, we need to check out a specific commit, and then build ourselves. The `pkg-old.sh` utility in this repo queries the `git log` and parses out the exact commit hash for a specific package version. We can then check this out, and hand over to the Termux docker build process.

I've tried this on ARM64 machines directly, but the best results are using the docker-based cross compilation toolchain on AMD64. Luckily `termux-packages` handles all of that for us, and we can simply run `./scripts/run-docker.sh ./build-package.sh <package-name>`.

Unfortunately it seems that checking out a commit isn't the only thing we need to do in some situations. Some other dependencies source archives become unavailable, so human input is required to build these dependencies at this stage. I'd have liked to have set up a CI job which handles this automatically, but at the moment this isn't possible.

I will be giving some thought into dependency management and `contrib/` dpkgs.

