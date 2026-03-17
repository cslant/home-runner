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
    # export NVM_DIR="$HOME/.nvm"
    # export NVM_DIR="/usr/local/nvm" # Moved to variables.sh
    # shellcheck disable=SC1091
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
    node_runner "$HOME_FE_DIR" build
  else
    node_runner "$HOME_FE_DIR" dev
  fi
  echo ''
}

build_fe2() {
  echo '⚙ Building home V2...'

  BUILD_MODE="$1"

  if [ "$BUILD_MODE" = "cache" ]; then
    # Build to builds/home-fe2 outside home-fe2
    CACHE_BUILD_DIR="$(dirname "$HOME_FE2_DIR")/builds/home-fe2"
    echo "  ∟ Cache build: $CACHE_BUILD_DIR"
    mkdir -p "$CACHE_BUILD_DIR"

    # cp but skip node_modules and .git
    cp -r --exclude='node_modules' --exclude='.git' "$HOME_FE2_DIR/." "$CACHE_BUILD_DIR/"
    cd "$CACHE_BUILD_DIR" || exit

    if [ ! -f "$CACHE_BUILD_DIR/.env" ]; then
      echo '  ∟ .env file missing, copying from .env.example...'
      cp "$CACHE_BUILD_DIR/.env.example" "$CACHE_BUILD_DIR/.env"
    fi

    fe2_resource_env

    if ! command -v nvm &> /dev/null; then
      # shellcheck disable=SC1091
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    nvm use "$NODE_VERSION"

    if ! command -v yarn &> /dev/null; then
      echo '  ∟ Installing yarn...'
      npm install -g yarn
    fi

    if ! command -v sass &> /dev/null; then
      echo '  ∟ Installing sass...'
      npm install -g sass
    fi

    echo '  ∟ Installing dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn install
    else
      npm install
    fi

    node_runner "$CACHE_BUILD_DIR" build-css
    echo '  ∟ INSTALLER build...'
    node_runner "$CACHE_BUILD_DIR" build

    # Move dist to home-fe2, clear old cache, keep zero downtime
    CACHE_TARGET="$HOME_FE2_DIR"
    echo "  ∟ Moving new dist to $CACHE_TARGET"
    rm -rf "$CACHE_TARGET/dist.old"
    mv "$CACHE_TARGET/dist" "$CACHE_TARGET/dist.old" 2>/dev/null || true
    rm -rf "$CACHE_TARGET/dist"
    mv "$CACHE_BUILD_DIR/dist" "$CACHE_TARGET/dist"
    echo "  ∟ dist moved, old cache removed, zero downtime maintained"
    cd "$HOME_FE2_DIR" || exit
    echo ''
    return
  fi

  BUILD_MODE="$1"
  cd "$HOME_FE2_DIR" || exit

  if [ ! -f "$HOME_FE2_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$HOME_FE2_DIR/.env.example" "$HOME_FE2_DIR/.env"
  fi

  fe2_resource_env

  if ! command -v nvm &> /dev/null; then
    # export NVM_DIR="$HOME/.nvm"
    export NVM_DIR="/usr/local/nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
  nvm use "$NODE_VERSION"

  if ! command -v yarn &> /dev/null; then
    echo '  ∟ Installing yarn...'
    npm install -g yarn
  fi

  if ! command -v sass &> /dev/null; then
    echo '  ∟ Installing sass...'
    npm install -g sass
  fi
  if [ ! -d "$HOME_FE2_DIR/node_modules" ] || [ "$BUILD_MODE" = "install" ]; then
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

  node_runner "$HOME_FE2_DIR" build-css

  echo '  ∟ INSTALLER build...'
  if [ "$ENV" = "prod" ]; then
    node_runner "$HOME_FE2_DIR" build-css
    node_runner "$HOME_FE2_DIR" build
    # Move dist to prod
    PROD_TARGET="$HOME_FE2_DIR/prod"
    echo "  ∟ Moving new dist to $PROD_TARGET"
    mkdir -p "$PROD_TARGET"
    rm -rf "$PROD_TARGET/dist.old"
    mv "$PROD_TARGET/dist" "$PROD_TARGET/dist.old" 2>/dev/null || true
    rm -rf "$PROD_TARGET/dist"
    cp -r "$HOME_FE2_DIR/dist" "$PROD_TARGET/dist"
    echo "  ∟ dist moved to prod, old cache removed, zero downtime maintained"
  else
    node_runner "$HOME_FE2_DIR" dev
  fi
  echo ''
}

worker() {
  echo '📽 Starting worker...'

  TARGET_DIR="$1"

  cd "$TARGET_DIR" || exit

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

  TARGET_DIR="$1"
  shift

  cd "$TARGET_DIR" || exit

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
    # shellcheck disable=SC2086
    composer $COMPOSER_COMMAND
    /usr/bin/php8.4 artisan key:generate
  else
    # shellcheck disable=SC2086
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

fe2_resource_env() {
  echo '🔧 Setting up home resource environment...'

  cd "$HOME_FE2_DIR" || exit

  HOME_RESOURCE_DIR="$HOME_DIR/home-resource"

  # copy folder "/Users/tanhongit/Data/CSlant/home-resource/public/v2" to "$HOME_FE2_DIR/public" if not exist
  if [ ! -d "$HOME_FE2_DIR/public" ]; then
    echo '  ∟ Copying public folder...'
    cp -r "$HOME_RESOURCE_DIR/public/v2" "$HOME_FE2_DIR/public"
  else
    echo '  ∟ Public folder already exist...'
  fi
}
