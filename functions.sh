#!/bin/bash

#Color definitions for terminal coloring
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

#Function definitions
function pass_replace {
	sed -i -r -e "s/$1[[:space:]]+[0-9]+/$2/g" /etc/login.defs
}

function sshd_replace {
	sed -i -r -e 's/PermitRootLogin[[:space:]]+.*/PermitRootLogin no/g' /etc/ssh/sshd_config
}

function info {
	printf "${CYAN}$1${NC}\n"
}

function run {
	#Check if command executed alright
	output=$(eval $1 2>&1)
	if [ $? -eq 0 ]; then
		printf "${GREEN}"
	else
		printf "${RED}"
	fi
	echo $output
	printf "${NC}"
}
