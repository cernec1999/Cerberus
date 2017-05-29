#!/bin/bash

. ./functions.sh

initUsers=$(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)
iter=0
for user in $initUsers
do
Users[$iter]=$user
Users2[$iter]=$user
iter=$iter+1
done
#echo ${Users[@]}



iter=0


info "Please enter the names of the users (be exact)"
read input


for usr in $input
do
Input[$iter]=$usr
iter=$iter+1
done
#echo ${Input[@]}
y=${#Users[@]}
u=${#Input[@]}



for ((i = 0; i < $u; i++)); do
  for ((j = 0; j < $y; j++)); do
    uvar=${Users[$j]}
    ivar=${Input[$i]}
    if [[ "$uvar" == "$ivar" ]];
    then
      Users2[$j]=""
    fi
  done
done

info "Examine the following users:"
printf "${RED}"
echo ${Users2[@]}
printf "${NC}"

#User groups
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

info "Please enter a new password to be set for all of the user accounts, and keep track of the password."
read -s pass1
info "Retype new password."
read -s pass2

while [ "$pass1" != "$pass2" ]
do
	printf "${RED}"
	echo "The passwords do not match!"
	printf "${NC}"
	info "Please enter a new password to be set for all of the user accounts."
	read -s pass1
	info "Retype new password."
	read -s pass2
done

for i in "${allUsers[@]}"
do
	#echo $pass1 | passwd $i --stdin
	echo $i:$pass1 | /usr/sbin/chpasswd
	info "Password changed for $i. This user will be forced to change the password on the next login."
	chage -m 7 -M 90 -I 10 -W 14 -d 0 $i
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
