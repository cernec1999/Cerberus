#!/bin/bash

#Get function data
. ./functions.sh

#Print out information
info "Cernebus is Ubuntu security software used for the hardening of a Linux system. Created by Christopher Cerne, Ben Manning, and Sean Webster."

#Run commands
bash useraccounts.sh
bash systempreferences.sh
