#!/bin/bash

home_sync() {
  echo '📥 Syncing Home...'
  echo ''

  case "$1" in
    fe)
      home_fe_sync
      ;;

    api)
      home_api_sync
      ;;

    resources)
      home_resources_sync
      ;;

    all)
      if [ "$USE_SUBMODULES" = true ]; then
        clone_submodules
      else
        home_resources_sync
        home_fe_sync
        home_api_sync
      fi
      ;;
  esac

  echo '✨ Syncing home repos done!'
  echo ''
}

clone_submodules() {
  echo "📥 Cloning submodules..."
  cd "$HOME_DIR" || exit

#  git submodule update --init --recursive
#  git submodule foreach git pull origin main -f || true
  echo ''
}

# ========================================
repo_sync_template() {
  REPO_NAME="$1"
  REPO_DIR="${2:-}"
  GIT_REPO_URL="${3:-}"

  if [ -z "$REPO_DIR" ]; then
    REPO_DIR="$REPO_NAME"
  fi

  echo "» Syncing $REPO_NAME repository..."
  cd "$HOME_DIR" || exit
  if [ -z "$(ls -A "$REPO_DIR")" ]; then
    echo "  ∟ Cloning $REPO_NAME repository..."

    if [ -z "$GIT_REPO_URL" ]; then
      git clone "$GIT_SSH_URL/$REPO_NAME.git" "$REPO_DIR"
    else
      git clone "$GIT_REPO_URL" "$REPO_DIR"
    fi
  else
    echo "  ∟ Pulling $REPO_NAME repository..."
    cd "$HOME_DIR/$REPO_DIR" || exit

    git checkout main -f
    git pull
  fi
  echo ''
}

home_fe_sync() {
  repo_sync_template 'home' 'home-fe'
}

home_api_sync() {
  repo_sync_template 'home-api'
}

home_resources_sync() {
  repo_sync_template 'home-resource' 'home-resource' 'git@github.com:cslant-community/home-resource.git'
}
