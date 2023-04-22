#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

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

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
}

setup_colors

msg "$ORANGE This will install Home Assistant Core 2023.4.4 in your $HOME/hass directory."
msg "$NOFORMAT Please CTRL+C now to abort, otherwise waiting 5 seconds and installing..."

sleep 1
echo -n " .1"

sleep 1
echo -n ".2"

sleep 1
echo -n ".3"

sleep 1
echo -n ".4"

sleep 1
echo ".5"

msg "$GREEN Installing now... $NOFORMAT"

sleep 1

pkg i git
git clone https://github.com/talss89/termux-home-assistant-installer.git
cd termux-home-assistant-installer && ./termux-home-assistant.sh install
