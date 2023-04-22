#!/usr/bin/env bash

DPKG_INSTALL_FLAGS="--force-confold"
APT_INSTALL_FLAGS="-o Dpkg::Options::=\"$DPKG_INSTALL_FLAGS\" --assume-yes"

pkg update
pkg upgrade $APT_INSTALL_FLAGS

pkg i tsu python nano termux-api make libjpeg-turbo make git rust python-cryptography libcrypt libffi binutils mosquitto wget libsodium python-numpy $APT_INSTALL_FLAGS

dpkg -i $DPKG_INSTALL_FLAGS ./contrib/ffmpeg_5.1.2-7_aarch64.deb
apt install -f $APT_INSTALL_FLAGS

python -m venv --without-pip hass
source hass/bin/activate

pip install wheel
pip install tzdata
pip install maturin
pip install setuptools
MATHLIB=m pip install aiohttp_cors==0.7.0
MATHLIB=m pip install PyTurboJPEG==1.6.7
CFLAGS=-Wno-implicit-function-declaration MATHLIB=m pip install numpy==1.23.2
pip install git+https://github.com/amitdev/lru-dict@5013406c409a0a143a315146df388281bfb2172d

SODIUM_INSTALL=system pip install pynacl

RUSTFLAGS="-C lto=n" CARGO_BUILD_TARGET="$(rustc -Vv | grep "host" | awk '{print $2}')"  CRYPTOGRAPHY_DONT_BUILD_RUST=1 pip install homeassistant==2023.4.4

# Run `hass` in check config mode, purely to install dependencies, and then quit.
hass --script check_config
