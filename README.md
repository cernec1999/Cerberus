# Cerberus
Cerberus is a Ubuntu-centered cyber security tool that hardens the operating system and prevents likely attacks from happening. It was developed by Christopher Cerne, Ben Manning, and Sean Webster, with inspiration drawn from the renowned CyberPatriot competitions.

You can download and run Cerberus using the following commands:
```
git clone git@github.com:cernec1999/Cerberus.git
cd Cerberus
sudo chmod +x main.sh
sudo ./main.sh
```

The core of Cerberus is divided into two subsections: **User Accounts** and **System Preferences**.
##User Accounts
The **User Accounts** section pertains to securing current Ubuntu accounts. It also pertains to detecting rogue users. It currently has the following features:
* Listing user accounts that should not be on the system
* Assigning administrators to the administrator group, and removing the admin group from users who should not be an administrator.
* Sets a new password for each user, except for the user executing the script
* Sets a password policy for each user, except for the user executing the script
* Looks for potentially hidden users (those users in one of these groups: getent group root wheel adm admin sudo)

##System Preferences
The **System Preferences** section pertains to securing the Ubuntu system as a whole. It currently has the following features:
* Sets the password policy to secure values (/etc/login.defs)
* Removes the root password
* Finds infringing media files
* Installs and secures OpenSSH
* Installs and configures firewall (ufw and gufw)
* Updates the system
* Installs and configures antivirus, and starts scan.
