#!/bin/bash

set -a
# shellcheck disable=SC1091
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

  build_fe2 | b2)
    build_fe2 "${2:-install}"
    ;;

  worker | start_worker | w)
    worker
    ;;

  worker2 | start_worker2 | w2)
    worker2
    ;;

  resources | sync_resources | r)
    home_resources_sync
    home_resource_env
    ;;

  all | a)
    home_sync all
    build_fe2 install
    build_api install
    worker2
    ;;

  *)
    usage
    exit 1
    ;;
esac
