#!/bin/bash

# Function to display red text
red_text() {
    echo -e "\e[91m$1\e[0m" >> /etc/issue
}

echo "Starting system customization" | systemd-cat -t "autoinstall"
mv /etc/issue /etc/issue_
# Display the warning message
touch /etc/issue
red_text "888       888        d8888 8888888b.  888b    888 8888888 888b    888  .d8888b.  888"
red_text "888   o   888       d88888 888   Y88b 8888b   888   888   8888b   888 d88P  Y88b 888"
red_text "888  d8b  888      d88P888 888    888 88888b  888   888   88888b  888 888    888 888"
red_text "888 d888b 888     d88P 888 888   d88P 888Y88b 888   888   888Y88b 888 888        888"
red_text "888d88888b888    d88P  888 8888888P   888 Y88b888   888   888 Y88b888 888  88888 888"
red_text "88888P Y88888   d88P   888 888 T88b   888  Y88888   888   888  Y88888 888    888 Y8P"
red_text "8888P   Y8888  d8888888888 888  T88b  888   Y8888   888   888   Y8888 Y88b  d88P    "
red_text "888P     Y888 d88P     888 888   T88b 888    Y888 8888888 888    Y888  Y8888P88  888"
echo -e "" >> /etc/issue
echo -e "SYSTEM INSTALLATION IN PROGRESS!" >> /etc/issue
echo -e "DO NOT DO ANYTHING YET, JUST WAIT UNTIL THE DESKTOP UI APPEARS" >> /etc/issue

echo "Installing cached packeges" | systemd-cat -t "autoinstall"
dpkg -i /var/cache/apt/archives/*deb

echo "Removing uneeded software" | systemd-cat -t "autoinstall"
apt-get remove -y update-manager-core

echo "Configuring autologin" | systemd-cat -t "autoinstall"
echo "autologin-user=tester" >> /usr/share/lightdm/lightdm.conf.d/50-greeter-wrapper.conf

echo "Running customfolder commands (/customfolder/post_install.sh)" | systemd-cat -t "autoinstall"
if [ -f /customfolder/post_install.sh ]; then
    /customfolder/post_install.sh;
else
    echo "/customfolder/post_install.sh not found"
fi

echo "Removing this script from systemd" | systemd-cat -t "autoinstall"
systemctl disable apt-install-cache.service
rm /usr/lib/systemd/system/apt-install-cache.service
rm /etc/issue
mv /etc/issue_ /etc/issue

echo "Done! Rebooting" | systemd-cat -t "autoinstall"
reboot
