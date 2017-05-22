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
printf "${GREEN}"
passwd -d root
printf "${NC}"

#Disable SSH Root Login
info "Disabling SSH Root Login"
sshd_replace

#SEAN'S COMMANDS
info "Finding infringing media files... User must delete the following files at their discretion"
printf "${RED}"
declare -a Extensions=('mp3' 'm3u' 'm4a' 'mov' 'mp4' 'wmv' 'wav' 'sh' 'jpg');
for i in "${Extensions[@]}"
do
find "/home" -type f -name "*.$i"
done
printf "${NC}"

info "Installing ufw"
printf "${GREEN}"
apt-get --yes install ufw gufw
printf "${NC}"

info "Enabling firewall"
printf "${GREEN}"
ufw enable
printf "${NC}"

info "Updating system"
printf "${GREEN}"
apt-get --yes update
apt-get --yes upgrade
apt-get --yes dist-upgrade
printf "${NC}"


info "Installing and configuring anti-virus software"
printf "${GREEN}"
apt-get --yes install clamav-daemon
/etc/init.d/clamav-freshclam stop
freshclam -v
/etc/init.d/clamav-freshclam start
printf "${NC}"

info "Scanning system... This may take a while."
clamscan -r / | grep FOUND >> /tmp/report.txt

info "Scan complete! Report saved in /tmp/report.txt. Displaying now."
printf "${RED}"
cat /tmp/report.txt
printf "${NC}"

