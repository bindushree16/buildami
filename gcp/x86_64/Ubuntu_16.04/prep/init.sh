#!/bin/bash
set -e
set -o pipefail

readonly NODE_ARCHITECTURE="$ARCHITECTURE"
readonly NODE_OPERATING_SYSTEM="$OS"
readonly INIT_SCRIPT_NAME="Docker_$DOCKER_VER.sh"

readonly NODE_SCRIPTS_TMP_LOC="/tmp/node.tar.gz"
readonly NODE_SCRIPTS_LOCATION="/root/node"
readonly NODE_SHIPCTL_LOCATION="$NODE_SCRIPTS_LOCATION/shipctl"

export install_docker_only=true

check_envs() {
    local expected_envs=(
    'ARCHITECTURE'
    'OS'
    'DOCKER_VER'
  )

  for env in "${expected_envs[@]}"
  do
    env_value=$(eval "echo \$$env")
    if [ -z "$env_value" ]; then
      echo "Missing ENV: $env"
      exit 1
    fi
  done
}

exec_cmd() {
  local cmd=$@
  eval $cmd
}

exec_grp() {
  local group_name=$1
  eval "$group_name"
}
__process_marker() {
  local prompt="$@"
  echo ""
  echo "# $(date +"%T") #######################################"
  echo "# $prompt"
  echo "##################################################"
}

__process_msg() {
  local message="$@"
  echo "|___ $@"
}

__process_error() {
  local message="$1"
  local error="$2"
  local bold_red_text='\e[91m'
  local reset_text='\033[0m'

  echo -e "$bold_red_text|___ $message$reset_text"
  echo -e "$error"
}

__process_msg "checking environment vars"
check_envs

__process_msg "adding dns settings to the node"
exec_cmd "echo 'supersede domain-name-servers 8.8.8.8, 8.8.4.4;' >> /etc/dhcp/dhclient.conf"

__process_msg "creating node scripts dir"
exec_cmd "mkdir -p $NODE_SCRIPTS_LOCATION"

__process_msg "extracting node scripts"
exec_cmd "tar -xzvf '$NODE_SCRIPTS_TMP_LOC' -C $NODE_SCRIPTS_LOCATION --strip-components=1"

__process_msg "Initializing node"
echo "NODE_ARCHITECTURE=$NODE_ARCHITECTURE"
echo "NODE_OPERATING_SYSTEM=$NODE_OPERATING_SYSTEM"
echo "NODE_SCRIPTS_LOCATION=$NODE_SCRIPTS_LOCATION"
echo "NODE_SHIPCTL_LOCATION=$NODE_SHIPCTL_LOCATION"
echo "install_docker_only=$install_docker_only"
source "$NODE_SCRIPTS_LOCATION/initScripts/$NODE_ARCHITECTURE/$NODE_OPERATING_SYSTEM/$INIT_SCRIPT_NAME"
