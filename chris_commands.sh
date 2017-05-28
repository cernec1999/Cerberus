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

#Prerequisite for installs
info "Updating package list"
run "apt-get --yes update"

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
run "apt-get --yes install openssh-server"
info "Disabling SSH Root Login"
sshd_replace

#Install and enable firewall
info "Installing firewall (ufw)"
run "apt-get --yes install ufw gufw"
info "Enabling firewall"
run "ufw enable"

#User account stuff
info "Please enter the valid computer administrators, using a space as a delimiter."
read input
arr=($input)

#get an array of all user accounts
allUsers=$(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)

#remove current user account from allUsers
delete=$(who | awk '{print $1}')
allUsers=("${allUsers[@]/$delete}")
allUsers=($allUsers)

#loop through every user account and make them standard
for i in "${allUsers[@]}"
do
	chage -m 7 -M 90 -I 10 -W 14 $i
	run "deluser $i sudo"
done

#loop through each admin user and make them sudo
for i in "${arr[@]}"
do
	#make the user a sudo user
	run "adduser $i sudo"
done

#print out users who are hidden that are root or admin or whatever
SAVEIFS=$IFS
# Change IFS to new line.
IFS=$'\n'
delim=($(getent group root wheel adm admin sudo))
# Restore IFS
IFS=$SAVEIFS
rogue_users=()
for i in "${delim[@]}"
do
	i=${i##*:}
	i=${i//,/ }
	i=${i=i;print}
	cur_arr=($i)
	rogue_users+=( "${cur_arr[@]}" )
done

unique=($(echo "${rogue_users[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

#remove current admins
delete+=( syslog )
delete+=( "${arr[@]}" )
unique=("${unique[@]/$delete}")

for del in ${delete[@]}
do
   unique=("${unique[@]/$del}") #Quotes when working with strings
done

#unique=$(${unique=unique;print})
final="${unique[*]}"
info "Returning a list of potentially rogue users. Please check these."
printf "${RED}"
echo ${final=final;print}
printf "${NC}"

#Update system
info "Updating system"
printf "${GREEN}"
apt-get update
apt-get --yes upgrade
apt-get --yes dist-upgrade
printf "${NC}"

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
