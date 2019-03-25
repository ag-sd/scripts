#!/bin/bash

#TODO
#Git, vscode
#Make install rerunnable

###########################
#####   HOUSEKEEPING  #####
###########################
rm -rf ~/Downloads
ln -s <MOUNT LOCATION>/Downloads/Downloads ~/Downloads

rm -rf ~/Documents
ln -s <MOUNT LOCATION>/Documents/ ~/Documents

rm -rf ~/Music
ln -s <MOUNT LOCATION>/Music/ ~/Music

rm -rf ~/Pictures
ln -s <MOUNT LOCATION>/Documents/Pictures ~/Pictures

rm -rf ~/Videos
ln -s <MOUNT LOCATION>/Documents/Videos ~/Videos

rm -rf ~/Public ~/Templates 

#http://blog.self.li/post/74294988486/creating-a-post-installation-script-for-ubuntu


###########################
###   Git and Intellij  ###
###########################
sudo apt-get install git
git config --global user.name "SD"
git config --global user.email <email id>
git config --list
read -r -p "Press any key to continue..." response

sudo snap install pycharm-community --classic

###########################
##### REMOVE PROGRAMS #####
###########################

echo "Deleting programs now ......................"
read -r -p "Press any key to continue..." response
programs_to_rm=(
		'Application Finder' 
		'Notes' 
		'Onboard' 
		'Orage Globaltime' 
		'Parole Media Player'
		'Thunderbird Mail'
		'Xfburn'
		'LibreOffice Math'
		'Pidgin'
		'Simple Scan'
		'Character Map'
		'Task Manager'
		'Dictionary'
		'Atril Document Viewer'
)

results=()
for prog in "${programs_to_rm[@]}"; do
    	echo "Looking For		$prog"
    	result="$(grep -lR "$prog" /usr/share/applications/*.desktop | tail -n1)"
    	result="$(dpkg -S "$result" | head -n1)"
    	echo "Found			$result"
    	results+=("${result%%: *}")
done

for app in ${results[@]}; do
	echo "*************** Attempting to remove $app ***************"
	sudo apt-get purge $app
done

echo "*************** Attempting to remove ALL GAMES ***************"
dpkg-query -W --showformat '${Section}\t${Package}\n' | grep ^games | awk '{ print $2 }' | xargs sudo apt-get purge -y



########################
##### ADD PROGRAMS #####
########################

echo "Adding programs now ......................"
read -r -p "Press any key to continue..." response
#Add repositories
results=()
repositories=(
	'clementine'	    'ppa:me-davidsansome/clementine'
	'ubuntu-make'	    'ppa:ubuntu-desktop/ubuntu-make'
	'Xfce goodies'      'ppa:xubuntu-dev/extras'
	'RClone Browser'    'ppa:mmozeiko/rclone-browser'
	'Q4Wine'            'ppa:tehnick/q4wine'
)

for (( i=0; i<${#repositories[@]} ; i+=2 )) ; do
    	echo "Searching for ${repositories[i]} -- ${repositories[i+1]}"
	result="$(grep -lR "${repositories[i]}" /etc/apt/sources.list /etc/apt/sources.list.d/* | wc -l)"
	if [[ ${result} > 0 ]]; then
		echo "Repository ${repositories[i+1]} was found in the system"
	else
		echo "Repository ${repositories[i+1]} was NOT found in the system. ADDING IT NOW"
		sudo add-apt-repository -y "${repositories[i+1]}"
	fi
	echo " "
done

#Additional configuration for chrome
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#Additional configuration for Dropbox
#sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

# basic update
apt-get -y --force-yes update

#Install VS-Code
#umake ide visual-studio-code

programs=(
    'libgstreamer*'
    'gstreamer*-plugins-base'
    'gstreamer*-plugins-good'
    'gstreamer*-plugins-bad'
    'gstreamer*-plugins-ugly'
    'gstreamer*-libav'
    'gstreamer*-doc'
    'gstreamer*-tools'
    'tumbler-plugins-extra'
    'ffmpegthumbnailer'
    'samba'
    'samba-common-bin'
    'system-config-samba'
    'thunar'
    'chromium-browser'
    'rclone-browser'
    'scite'
    'meld'
    #'wine'
    'q4wine'
    'puddletag'
    'gnome-disk-utility'
    'foo'
    'bar'
)

install=()

for (( i=0; i<${#programs[@]} ; i+=1 )) ; do
    printf "Searching for installed program ${programs[i]}\n"
    result="$(apt-cache policy "${programs[i]}" | grep Installed | grep -v none)"
    if [[ ${result} > 0 ]]; then
		printf "\t\tApp ${programs[i]} was found in the system as $result\n"
	else
		printf "\t\tApp ${programs[i]} was NOT found in the system and will be installed.\n"
		#sudo apt-get install "${programs[i]}"
		install+=(${programs[i]})
	fi
done

printf "**********************The following applications will be installed**********************\n\n"
printf '%s\n' "${install[@]}"
read -r -p "Press any key to continue..." response

sudo apt-get update
sudo apt-get install -y "${install[@]}"

# RClone
curl https://rclone.org/install.sh | sudo bash

#Dropbox
#wget "http://www.dropbox.com/download?plat=lnx.x86_64"  -P /tmp/
#sudo dpkg -i '/tmp/download?plat=lnx.x86_64'

#Bleachbit
wget https://download.bleachbit.org/bleachbit_2.2_all_ubuntu1810.deb -P /tmp/
sudo gdebi /tmp/bleachbit_2.2_all_ubuntu1810.deb

##Mount the nas Requires user entry
#    #Backup the fstabs file
#    cp /etc/fstab /etc/fstab_backup
#
#    #Add New entry
#    echo Enter Share name:
#    read share
#    echo Enter mount point:
#    read mt_pt
#    echo Enter your NAS username:
#    read username
#    echo Enter your NAS password:
#    read password
#    echo -e "$share\t$mt_pt\tcifs\tusername=$username,password=$password,iocharset=utf8,file_mode=0777,dir_mode=0777,vers=1.0\t0\t0" >> /etc/fstab

#Powershell on Linux
# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Register the Microsoft Ubuntu repository
curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/18.04/prod.list

# Install PowerShell
sudo snap install powershell --classic

# Start PowerShell
pwsh

# Citrix installation
# https://askubuntu.com/questions/901448/citrix-receiver-error-1000119
cd /opt/Citrix/ICAClient/keystore/
rm -rf cacerts
ln -s /etc/ssl/certs cacerts

# requires clicks
sudo apt-get install -y --dry-run ubuntu-restricted-extras


#Update the System
sudo apt autoremove
sudo apt-get upgrade

echo "DONE"
