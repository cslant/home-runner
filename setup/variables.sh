#!/bin/bash

# shellcheck disable=SC2034
CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
HOME_DIR="$SOURCE_DIR"
HOME_FE_DIR="$HOME_DIR/home-fe"
HOME_API_DIR="$HOME_DIR/home-api"
ENV=${ENV:-prod}
GIT_SSH_URL=${GIT_SSH_URL:-git@github.com:cslant}
USE_SUBMODULES=${USE_SUBMODULES:-false}
