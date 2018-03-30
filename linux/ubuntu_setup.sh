#!/bin/bash

#TODO
#Stacer, Dropbox, Git, vscode
#Make install rerunnable

###########################
#####   HOUSEKEEPING  #####
###########################
rm -rf ~/Downloads
ln -s /media/sheldon/Downloads/ ~/Downloads

rm -rf ~/Documents
ln -s /media/sheldon/Documents/ ~/Documents

rm -rf ~/Music
ln -s /media/sheldon/Music/ ~/Music

rm -rf ~/Pictures ~/Public ~/Templates ~/Videos

#http://blog.self.li/post/74294988486/creating-a-post-installation-script-for-ubuntu

###########################
##### REMOVE PROGRAMS #####
###########################

echo "Deleting programs now ......................"
sleep 2
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
sleep 2
#Add repositories
results=()
repositories=(
	#Variety
	#'peterlevi'	'ppa:peterlevi/ppa'
	#Pinta	
	#'pinta'		'ppa:pinta-maintainers/pinta-stable'
	#Clementine			
	'clementine'	'ppa:me-davidsansome/clementine'			
	#Dropbox				
	#'dropbox'	'deb http://linux.dropbox.com/ubuntu $(lsb_release -sc) main'
	#Chrome
	#'chrome'	'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
	'ubuntu-make'	'ppa:ubuntu-desktop/ubuntu-make'
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
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#Additional configuration for Dropbox
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E

# basic update
#apt-get -y --force-yes update

#Install Chromium

#Install VLC

#Install Variety

#Install VS-Code
#umake ide visual-studio-code


##TODO Make this rerunnable
#sudo apt-get install variety vlc synaptic pinta linux-headers-generic \
#		p7zip p7zip-full p7zip-rar redshift redshift-gtk gdebi arc-theme xfce4-mount-plugin \
#		libappindicator1 libindicator7 clementine git gnome-disk-utility cifs-utils wine q4wine
		
		


##Stacer
#stacer:i386 depends on git.
# stacer:i386 depends on libc6.
# stacer:i386 depends on libcap2.
# stacer:i386 depends on libgtk2.0-0.
# stacer:i386 depends on libudev0 | libudev1.
# stacer:i386 depends on libgcrypt11 | libgcrypt20.
#stacer:i386 depends on libnotify4.
# stacer:i386 depends on libnss3.
#stacer:i386 depends on libxtst6.
# stacer:i386 depends on python.
#wget https://github.com/oguzhaninan/Stacer/releases/download/v1.0.4/Stacer_1.0.4_i386.deb -P /tmp/
#sudo dpkg -i /tmp/Stacer_1.0.4_i386.deb

#Add to FS Tabs
#sudo mount -a


#Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp/
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb

#Dropbox
wget "http://www.dropbox.com/download?plat=lnx.x86_64"  -P /tmp/
sudo dpkg -i ‘/tmp/tmp/download?plat=lnx.x86_64’

#Git Config
git config --global user.email "sheldon.anitta@gmail.com"
git config --global user.name "ag-sd"

#Install Spotify
snap install spotify

#Mount the nas Requires user entry
    #Backup the fstabs file
    cp /etc/fstab /etc/fstab_backup

    #Add New entry
    echo Enter Share name:
    read share
    echo Enter mount point:
    read mt_pt
    echo Enter your NAS username:
    read username
    echo Enter your NAS password:
    read password
    echo -e "$share\t$mt_pt\tcifs\tusername=$username,password=$password,iocharset=utf8,file_mode=0777,dir_mode=0777,vers=1.0\t0\t0" >> /etc/fstab

#Powershell on Linux
# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Register the Microsoft Ubuntu repository
curl https://packages.microsoft.com/config/ubuntu/17.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list

# Update the list of products
sudo apt update

# Install PowerShell
sudo apt install powershell

# Start PowerShell
pwsh

# requires clicks
sudo apt-get install -y --dry-run ubuntu-restricted-extras


#Update the System
sudo apt autoremove
sudo apt-get upgrade

echo "DONE"