#!/bin/sh

###
# project https://github.com/MetaCubeX/metacubexd
###

set -e
# Initialize variables
bindir=/home/xd
PROXY=127.0.0.1:7890


curl_install() {
  curl -x $PROXY -L https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz -o /tmp/compressed-dist.tgz
  tar zxvf /tmp/compressed-dist.tgz -C $bindir
}


main() {
  mkdir -p $bindir
  rm -rf $bindir/*
  curl_install

  exit 0
}

uninstall() {
  rm -rf $bindir
  exit 0
}

help() {
  echo -e "usage: install.sh ACTION [OPTION]...

ACTION:
install                   Install/Update sing-box
remove                    Remove sing-box
help                      Show help
If no action is specified, then help will be selected

"
  exit 0
}
# Parse command line arguments
for arg in "$@"; do
  case $arg in
    help)
      action="help"
      ;;
    remove)
      action="remove"
      ;;
    install)
      action="install"
      ;;
    *)
      echo "Invalid argument: $arg"
      exit 1
      ;;
  esac
done

# Perform action based on user input
case "$action" in
  help)
    help
    ;;
  remove)
    uninstall
    ;;
  install)
    main
    ;;
  *)
    echo "No action specified. Exiting..."
    ;;
esac

help