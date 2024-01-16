#!/bin/bash

###
# fork https://github.com/chise0713/sing-box-install
# Thank you for the work results of user @ chise0713
###

set -e
# Initialize variables
beta=false
bindir=/home/clash
binfile=$bindir/clash


identify_the_operating_system_and_architecture() {
  if [[ "$(uname)" == 'Linux' ]]; then
    case "$(uname -m)" in
      'i386' | 'i686')
        MACHINE='386'
        ;;
      'amd64' | 'x86_64')
        MACHINE='amd64'
        ;;
      'armv5tel')
        MACHINE='arm'
        ;;
      'armv6l')
        MACHINE='arm'
        ;;
      'armv7' | 'armv7l')
        MACHINE='arm'
        ;;
      'armv8' | 'aarch64')
        MACHINE='arm64'
        ;;
      'mips')
        MACHINE='mips'
        ;;
      'mipsle')
        MACHINE='mipsle'
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
    
  else
    echo "error: This operating system is not supported."
    exit 1
  fi
}



curl_install() {
  [[ $MACHINE == amd64 ]] && CURL_MACHINE=amd64
  [[ $MACHINE == arm ]] && CURL_MACHINE=armv7
  [[ $MACHINE == arm64 ]] && CURL_MACHINE=arm64
  [[ $MACHINE == s390x ]] && CURL_MACHINE=s390x
  if [[ $CURL_MACHINE == amd64 ]] || [[ $CURL_MACHINE == arm64 ]] || [[ $CURL_MACHINE == armv7 ]] || [[ $CURL_MACHINE == s390x ]]; then
    if [[ $beta == false ]];then
      META_VERSION=$(curl https://api.github.com/repos/MetaCubeX/mihomo/releases|grep -oP "mihomo-linux-$CURL_MACHINE-v\d+\.\d+\.\d+"| sort -Vru | head -n 1)
      echo "Newest version found: $META_VERSION"
    elif [[ $beta == true ]];then
      META_VERSION=$(curl https://api.github.com/repos/MetaCubeX/mihomo/releases|grep -oP "mihomo-linux-$CURL_MACHINE-alpha-[0-9]+"| sort -Vru | head -n 1)
      echo "Newest beta/rc version found: $META_VERSION"
      CURL_TAG=Prerelease-Alpha
    else
      echo -e "\033[1;31m\033[1mERROR:\033[0m beta type is not true or false.\nExiting."
    fi
    if [[ -z $CURL_TAG ]];then 
      curl -o /tmp/$META_VERSION.gz -L https://github.com/MetaCubeX/mihomo/releases/latest/download/$META_VERSION.gz
    else
      curl -o /tmp/$META_VERSION.gz -L https://github.com/MetaCubeX/mihomo/releases/download/$CURL_TAG/$META_VERSION.gz
    fi
    # gunzip /tmp/$META_VERSION.gz -C /tmp
    # cp -rf /tmp/clash.meta-linux-$CURL_MACHINE $binfile
    gunzip -c /tmp/$META_VERSION.gz > $binfile
    chmod +x $binfile
    echo -e "\
Installed: $binfile\
"
  else
    echo -e "\
Machine Type Not Support
Try to use \"--type=go\" to install\
"
    exit 1
  fi
}


main() {
  mkdir -p $bindir
  # on openwrt : opkg update && opkg install grep
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

OPTION:
  install:
    --beta                    If it's specified, the scrpit will install latest Pre-release version of sing-box. 
                              If it's not specified, the scrpit will install latest release version by default.
"
  exit 0
}
# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --beta)
      beta=true
      ;;
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