#!/bin/bash

build_fe() {
  echo '⚙ Building home...'

  BUILD_TYPE="$1"

  cd "$HOME_FE_DIR" || exit

  if [ ! -f "$HOME_FE_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$HOME_FE_DIR/.env.example" "$HOME_FE_DIR/.env"
  fi

  home_resource_env

  if ! command -v nvm &> /dev/null; then
    # shellcheck disable=SC2155
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
  nvm use "$NODE_VERSION"

  if ! command -v yarn &> /dev/null; then
    echo '  ∟ Installing yarn...'
    npm install -g yarn
  fi

  if [ ! -d "$HOME_FE_DIR/node_modules" ] || [ "$BUILD_TYPE" = "install" ]; then
    echo '  ∟ Installing dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn install
    else
      npm install
    fi
  else
    echo '  ∟ Updating dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn upgrade
    else
      npm update
    fi
  fi

  echo '  ∟ INSTALLER build...'
  if [ "$ENV" = "prod" ]; then
    node_runner build
  else
    node_runner dev
  fi
  echo ''
}

worker() {
  echo '📽 Starting worker...'

  cd "$HOME_FE_DIR" || exit

  if pm2 show "$WORKER_NAME" > /dev/null; then
    echo "  ∟ Restarting $WORKER_NAME..."
    pm2 reload ecosystem.config.cjs
  else
    echo "  ∟ Starting $WORKER_NAME..."

    pm2 start ecosystem.config.cjs
    pm2 save
  fi
  echo ''
}

node_runner() {
  echo '🏃‍♂️ Running node...'

  cd "$HOME_FE_DIR" || exit

  if [ "$INSTALLER" = "yarn" ]; then
    yarn "$@"
  else
    npm run "$@"
  fi
  echo ''
}

# ========================================

build_api() {
  echo '⚙ Building home API (Laravel)...'

  if [ "$1" == "install" ]; then
    COMPOSER_COMMAND="install"
  else
    COMPOSER_COMMAND="update"
  fi

  cd "$HOME_API_DIR" || exit

  if [ ! -f "$HOME_API_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$HOME_API_DIR/.env.example" "$HOME_API_DIR/.env"
    composer $COMPOSER_COMMAND
    php artisan key:generate
  else
    composer $COMPOSER_COMMAND
  fi

  echo ''
}

home_resource_env() {
  echo '🔧 Setting up home resource environment...'

  cd "$HOME_FE_DIR" || exit

  HOME_RESOURCE_DIR="$HOME_DIR/home-resource"

  # check and replace "PUBLIC_DIR=/Users/tanhongit/Data/CSlant/home-resource/public" to "PUBLIC_DIR=$HOME_RESOURCE_DIR/public"
  if [ -f "$HOME_FE_DIR/.env" ] && ! grep -q "PUBLIC_DIR=$HOME_RESOURCE_DIR/public" "$HOME_FE_DIR/.env"; then
    echo '  ∟ Setting up PUBLIC_DIR...'
    awk -v HOME_RESOURCE_DIR="$HOME_RESOURCE_DIR" '/PUBLIC_DIR=/{gsub(/PUBLIC_DIR=.*/, "PUBLIC_DIR="HOME_RESOURCE_DIR"/public")}1' "$HOME_FE_DIR/.env" >"$HOME_FE_DIR/.env.tmp" && mv "$HOME_FE_DIR/.env.tmp" "$HOME_FE_DIR/.env"
  else
    echo '  ∟ PUBLIC_DIR already set up...'
  fi
}
