#!/bin/bash

welcome() {
  echo '
██╗  ██╗ ██████╗ ███╗   ███╗███████╗    ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗
██║  ██║██╔═══██╗████╗ ████║██╔════╝    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
███████║██║   ██║██╔████╔██║█████╗      ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
██╔══██║██║   ██║██║╚██╔╝██║██╔══╝      ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
  '
  echo ''
  echo '⚡ Welcome to the home runner!'
  echo ''
  echo "- Current dir        : $CURRENT_DIR"
  echo "- Source dir         : $SOURCE_DIR"
  echo "- Home dir           : $HOME_DIR"
  echo ''
}

usage() {
  welcome
  echo "Usage: bash $0 [command] [args]"
  echo ''
  echo 'Commands:'
  echo '  welcome         Show welcome message'
  echo '  help            Show this help message'
  echo '  home_sync       Sync Home repository'
  echo '  build           Build home'
  echo '  worker          Start worker'
  echo '  all             Sync git and Home repository, build Home'
  echo ''
  echo 'Args for home_sync:'
  echo '  fe              Sync frontend home repository'
  echo '  api             Sync backend API home repository'
  echo '  all             Sync all Home repository'
  echo ''
  echo 'Args for build:'
  echo '  install         Install dependencies and build (default, if not set)'
  echo '  update          Update dependencies and build'
  echo ''
  echo 'Example:'
  echo "  bash $0 home_sync all"
  echo "  bash $0 build"
  echo ''
}
