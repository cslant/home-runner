#!/bin/bash

build() {
  echo '⚙ Building home...'

  BUILD_TYPE="$1"

  cd "$HOME_DIR" || exit

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

  cd "$HOME_DIR" || exit

  if [ "$INSTALLER" = "yarn" ]; then
    yarn "$@"
  else
    npm run "$@"
  fi
  echo ''
}
