#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

TERMUX_REPO_URL=${TERMUX_REPO_URL:-https://github.com/termux/termux-packages}
TERMUX_REPO_DIR=${TERMUX_REPO_DIR:-~/.termux-packages}
PREFIX=${PREFIX:-}

if [[ "$PREFIX" == *"com.termux"* ]]; then
    echo "Running in Termux"
    IS_TERMUX=1
else
    echo "Running in cross-compile mode"
    IS_TERMUX=
fi;

commit_hash=""

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") <package name> [-v | --version <version>]

Utlity to build old Termux packages by seaching git logs

EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
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
  version=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -v | --version) # example named parameter
      version="${2-}"
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

ensure_repo() {
    if [ ! -d "$TERMUX_REPO_DIR" ]; then
        echo "$TERMUX_REPO_DIR does not exist. Cloning $TERMUX_REPO_URL now..."
        mkdir -p $TERMUX_REPO_DIR
        git clone $TERMUX_REPO_URL $TERMUX_REPO_DIR
        
        if [ -z "$IS_TERMUX" ]; then
            cd $TERMUX_REPO_DIR; ./scripts/setup-ubuntu.sh
            cd $TERMUX_REPO_DIR; ./scripts/setup-android-sdk.sh
        fi;
    else
        echo "$TERMUX_REPO_DIR exists, attempting to update..."
        cd $TERMUX_REPO_DIR; git pull;
    fi
}

get_commit() {
    commit_hash=$(cd "$TERMUX_REPO_DIR"; git log -S "TERMUX_PKG_VERSION=\"$2\"" --pretty=format:'{^^^^date^^^^:^^^^%ci^^^^,^^^^commit^^^^:^^^^%H^^^^,^^^^subject^^^^:^^^^%s^^^^}' packages/$1/build.sh | sed 's/"/\\"/g' | sed 's/\^^^^/"/g' | jq -s ".[] | select(.subject | test(\"$2\"))" | jq -r .commit)
}

build_package() {
    cd $TERMUX_REPO_DIR; ./build-package.sh ${args[0]} -s
}

[[ ${#args[@]} -eq 0 ]] && usage && die;


ensure_repo
get_commit "${args[0]}" "${version}"

if [ -z "$commit_hash" ]; then
    echo "No release could be found for ${args[0]}@${version}"
    exit 1
fi

echo "Found $commit_hash which appears to be the parent for ${args[0]}@${version}"
echo "Commit information: $TERMUX_REPO_URL/commit/$commit_hash"

build_package


