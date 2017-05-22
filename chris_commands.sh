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

#Update system
info "Updating system"
run "apt-get --yes update"
run "apt-get --yes upgrade"
run "apt-get --yes dist-upgrade"

#Install openssh and disable ssh root login
info "Installing openssh"
run "apt-get --yes install openssh-server"
info "Disabling SSH Root Login"
sshd_replace

#Install and enable firewall
info "Installing firewall (ufw)"
run "apt-get --yes install ufw gufw"
info "Enabling firewall"
run "ufw enable"

#Configure anti-virus
info "Installing and configuring anti-virus software"
run "apt-get --yes install clamav-daemon"
run "/etc/init.d/clamav-freshclam stop"
run "freshclam -v"
run "/etc/init.d/clamav-freshclam start"

#Scanning system
info "Scanning system... This may take a while."
run "clamscan -r / | grep FOUND >> /tmp/report.txt"

#Print viruses
info "Scan complete! Report saved in /tmp/report.txt. Displaying now."
printf "${RED}"
cat /tmp/report.txt
printf "${NC}"

