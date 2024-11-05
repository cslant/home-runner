#!/bin/bash

build_fe() {
  echo '⚙ Building home...'

  BUILD_TYPE="$1"

  cd "$HOME_FE_DIR" || exit

  if [ ! -f "$HOME_FE_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$HOME_FE_DIR/.env.example" "$HOME_FE_DIR/.env"
  fi

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

