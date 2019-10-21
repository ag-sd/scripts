#!/bin/bash

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
    'Tomboy Notes'
    'GNU Image Manipulation Program'
    'HexChat'
    'Rhythmbox'
    'Screen Reader'
)

results=('gnome-orca')
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
#### INTERNET SPEED ####
########################
lsmod | grep iwlwifi
# Does the terminal output contain the word iwlwifi (in red letters)? If so, proceed with the next step.
echo "options iwlwifi 11n_disable=8" | sudo tee /etc/modprobe.d/iwlwifi11n.conf

# To undo
# sudo rm -v /etc/modprobe.d/iwlwifi11n.conf


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
	'Xfce goodies'    'ppa:xubuntu-dev/extras'
	'Q4Wine'          'ppa:tehnick/q4wine'
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

# basic update
apt-get -y --force-yes update

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
    'scite'
    'meld'
    'q4wine'
    'puddletag'
    'gnome-disk-utility'
    'ristretto'
    'audacious'
    'clementine'
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

#Improve font support
wget http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb -P ~/Downloads
sudo apt install ~/Downloads/ttf-mscorefonts-installer_3.7_all.deb
sudo dpkg-reconfigure fontconfig
sudo apt-get install fonts-crosextra-carlito fonts-crosextra-caladea

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
#    echo -e #"$share\t$mt_pt\tcifs\tusername=$username,password=$password,iocharset=utf8,file_mode=0777,dir_mode=0777,vers=1.0\t0\t0" >> /etc/fstab

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
