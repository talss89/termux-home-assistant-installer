#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") install [-h] [-v] [-f] -p param_value arg1 [arg2...]

A script to manage Home Assistant Core on Termux / Android. 

-- THIS IS UNSUPPORTED BY HOME ASSISTANT, USE AT OWN RISK. --

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  rm -f "$PREFIX/etc/apt/apt.conf.d/99-ha-unattended"
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  # [[ -z "${param-}" ]] && die "Missing required parameter: param"
  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

do_install() {
  APT_INSTALL_FLAGS="--assume-yes"
  export DEBIAN_FRONTEND=noninteractive

  cp "$script_dir/etc/apt/apt.conf.d/99-ha-unattended" "$PREFIX/etc/apt/apt.conf.d/99-ha-unattended"

  pkg update $APT_INSTALL_FLAGS
  apt upgrade $APT_INSTALL_FLAGS

  pkg i tsu python nano termux-api make libjpeg-turbo make git rust python-cryptography libcrypt libffi binutils mosquitto wget libsodium python-numpy $APT_INSTALL_FLAGS

  dpkg -i ./contrib/ffmpeg_5.1.2-7_aarch64.deb || true
  apt install -f $APT_INSTALL_FLAGS

  rm -f "$PREFIX/etc/apt/apt.conf.d/99-ha-unattended"

  cd ~

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

}

[[ ${#args[@]} -eq 0 ]] && usage && die;


if [ "${args[0]}" == "install" ]; then
  do_install;
  msg "$GREEN Installation complete. To start Home Assistant, run:"
  msg "$BLUE source hass/bin/activate && hass -v $NOFORMAT"
  msg "Remember, this may take a long time while 'hass' installs lazy dependencies. This will only happen at first boot."
fi
