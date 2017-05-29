#!/bin/bash
. ./functions.sh

#Prerequisite for installs
info "Updating package list"
printf "${GREEN}"
apt-get --yes update
printf "${NC}"

#Make sure password policy is up to date
info "Setting password policy"
pass_replace PASS_MAX_DAYS "PASS_MAX_DAYS 90"
info "Setting PASS_MAX_DAYS to 90"
pass_replace PASS_MIN_DAYS "PASS_MIN_DAYS 7"
info "Setting PASS_MIN_DAYS to 7"
pass_replace PASS_WARN_AGE "PASS_WARN_AGE 14"
info "Setting PASS_WARN_AGE to 14"

#Remove root password
info "Removing root password"
run "passwd -d root"

info "Finding infringing media files... User must delete the following files at their discretion"
printf "${RED}"
declare -a Extensions=('mp3' 'm3u' 'm4a' 'mov' 'mp4' 'wmv' 'wav' 'sh' 'jpg');
for i in "${Extensions[@]}"
do
	find "/home" -type f -name "*.$i"
done
printf "${NC}"

#Install openssh and disable ssh root login
info "Installing openssh"
printf "${GREEN}"
apt-get --yes install openssh-server
printf "${NC}"
info "Disabling SSH Root Login"
sshd_replace

#Install and enable firewall
info "Installing firewall (ufw)"
printf "${GREEN}"
apt-get --yes install ufw gufw
printf "${NC}"
info "Enabling firewall"
run "ufw enable"

#Update system
info "Updating system"
printf "${GREEN}"
apt-get update
apt-get --yes upgrade
apt-get --yes dist-upgrade
printf "${NC}"

#Configure anti-virus
info "Installing and configuring anti-virus software... This may take a while."
printf "${GREEN}"
apt-get --yes install clamav-daemon
/etc/init.d/clamav-freshclam stop
freshclam -v
/etc/init.d/clamav-freshclam start
printf "${NC}"

#Scanning system
info "Scanning system... This may take a while."
run "clamscan -r / | grep FOUND >> /tmp/report.txt"

#Print viruses
info "Scan complete! Report saved in /tmp/report.txt. Displaying now."
printf "${RED}"
cat /tmp/report.txt
printf "${NC}"
