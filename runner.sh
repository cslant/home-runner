#!/bin/bash

set -a
source .env
set +a
set -ue

# shellcheck disable=SC1091
source setup/variables.sh
source setup/tips.sh
source setup/git.sh
source setup/tools.sh
source setup/functions.sh

case "$1" in
  welcome)
    welcome
    ;;

  help | tips)
    usage
    ;;

  home_sync)
    home_sync "$2"
    ;;

  build | build_home | b)
    build_fe "${2:-install}"
    ;;

  worker | start_worker | w)
    worker
    ;;

  all | a)
    home_sync all
    build_fe install
    build_api install
    worker
    ;;

  *)
    usage
    exit 1
    ;;
esac
