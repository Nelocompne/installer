#!/bin/sh
set -e
# Initialize variables
beta=false
bindir=/home/sing-box
binfile=$bindir/sing-box


identify_the_operating_system_and_architecture() {
  if [[ "$(uname)" == 'MINGW64_NT-10.0-22621' ]]; then
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
      SING_VERSION=$(curl https://api.github.com/repos/SagerNet/sing-box/releases|grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CURL_MACHINE"| sort -Vru | head -n 1)
      echo "Newest version found: $SING_VERSION"
    elif [[ $beta == true ]];then
      SING_VERSION=$(curl https://api.github.com/repos/SagerNet/sing-box/releases|grep -oP "sing-box-\d+\.\d+\.\d+(-rc|-beta|-alpha)\.\d+-linux-$CURL_MACHINE"| sort -Vru | head -n 1)
      echo "Newest beta/rc version found: $SING_VERSION"
      CURL_TAG=$(echo $SING_VERSION | grep -oP "\d+\.\d+\.\d+(-rc|-beta|-alpha)\.\d+")
    else
      echo -e "\033[1;31m\033[1mERROR:\033[0m beta type is not true or false.\nExiting."
    fi
    if [[ -z $CURL_TAG ]];then 
      curl -o /tmp/$SING_VERSION.tar.gz -L https://github.com/SagerNet/sing-box/releases/latest/download/$SING_VERSION.tar.gz
    else
      curl -o /tmp/$SING_VERSION.tar.gz -L https://github.com/SagerNet/sing-box/releases/download/v$CURL_TAG/$SING_VERSION.tar.gz
    fi
    tar -xzf /tmp/$SING_VERSION.tar.gz -C /tmp
    cp -rf /tmp/$SING_VERSION/sing-box $binfile
    chmod +x $binfile
    echo -e "\
Installed: binfile\
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
  identify_the_operating_system_and_architecture
  curl_install

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
    --go                      If it's specified, the scrpit will use go to install sing-box. 
                              If it's not specified, the scrpit will use curl by default.
    --tag=[Tags]              sing-box Install tag, if you specified it, the script will use go to install sing-box, and use your custom tags. 
                              If it's not specified, the scrpit will use offcial default Tags by default.
    --cgo                     Set \`CGO_ENABLED\` environment variable to 1
    --win                     If it's specified, the scrpit will use go to compile windows version of sing-box. 
  remove:
    --purge                   Remove all the sing-box files, include logs, configs, etc
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