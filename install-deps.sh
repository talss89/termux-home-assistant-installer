#!/usr/bin/env bash
pkg update
pkg upgrade -y

pkg i tsu python nano termux-api make libjpeg-turbo make git rust python-cryptography libcrypt libffi binutils mosquitto wget libsodium python-numpy -y

dpkg i ./contrib/ffmpeg_5.1.2-7_aarch64.deb

python -m venv --without-pip hass
source hass/bin/activate

pip install wheel
pip install tzdata
pip install maturin
pip install setuptools
MATHLIB=m pip install aiohttp_cors==0.7.0
MATHLIB=m pip install PyTurboJPEG==1.6.7

pip install git+https://github.com/amitdev/lru-dict@5013406c409a0a143a315146df388281bfb2172d
SODIUM_INSTALL=system pip install pynacl

RUSTFLAGS="-C lto=n" CARGO_BUILD_TARGET="$(rustc -Vv | grep "host" | awk '{print $2}')"  CRYPTOGRAPHY_DONT_BUILD_RUST=1 pip install homeassistant==2023.4.4