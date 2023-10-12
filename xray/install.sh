#!/usr/bin/env bash

###
# https://github.com/XTLS/Xray-install
# Thank you for the work results of XTLS
###


set -e

bindir=/home/xray
binfile=$bindir/xray

identify_the_operating_system_and_architecture() {
  if [[ "$(uname)" != 'Linux' ]]; then
    echo "error: This operating system is not supported."
    exit 1
  fi
  case "$(uname -m)" in
    'i386' | 'i686')
      MACHINE='32'
      ;;
    'amd64' | 'x86_64')
      MACHINE='64'
      ;;
    'armv5tel')
      MACHINE='arm32-v5'
      ;;
    'armv6l')
      MACHINE='arm32-v6'
      grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
      ;;
    'armv7' | 'armv7l')
      MACHINE='arm32-v7a'
      grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
      ;;
    'armv8' | 'aarch64')
      MACHINE='arm64-v8a'
      ;;
    'mips')
      MACHINE='mips32'
      ;;
    'mipsle')
      MACHINE='mips32le'
      ;;
    'mips64')
      MACHINE='mips64'
      lscpu | grep -q "Little Endian" && MACHINE='mips64le'
      ;;
    'mips64le')
      MACHINE='mips64le'
      ;;
    'ppc64')
      MACHINE='ppc64'
      ;;
    'ppc64le')
      MACHINE='ppc64le'
      ;;
    'riscv64')
      MACHINE='riscv64'
      ;;
    's390x')
      MACHINE='s390x'
      ;;
    *)
      echo "error: The architecture is not supported."
      exit 1
      ;;
  esac
  if [[ ! -f '/etc/os-release' ]]; then
    echo "error: Don't use outdated Linux distributions."
    exit 1
  fi
  # Do not combine this judgment condition with the following judgment condition.
  ## Be aware of Linux distribution like Gentoo, which kernel supports switch between Systemd and OpenRC.
  
}

curl_install() {
  curl -o /tmp/Xray-linux-$MACHINE.zip -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$MACHINE.zip
  unzip /tmp/Xray-linux-$MACHINE.zip -d $bindir
  chmod +x $binfile
}

main() {
  mkdir -p $bindir
  identify_the_operating_system_and_architecture
  curl_install

  exit 0
}

uninstall() {
  rm -rf $bindir
    echo -e "\
Removed: $bindir
"
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