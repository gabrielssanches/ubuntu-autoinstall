#!/bin/bash

echo "Installing cached packeges" | systemd-cat -t "autoinstall"
dpkg -i /var/cache/apt/archives/*deb

echo "Removing uneeded software" | systemd-cat -t "autoinstall"
apt-get remove -y update-manager-core

echo "Configuring autologin" | systemd-cat -t "autoinstall"
echo "autologin-user=tester" >> /usr/share/lightdm/lightdm.conf.d/50-greeter-wrapper.conf

if [ -f /customfolder/custom_install.sh ]; then
    echo "Running /customfolder/custom_install.sh" | systemd-cat -t "autoinstall"
    /customfolder/custom_install.sh;
else
    echo "/customfolder/custom_install.sh not found"
fi

echo "Adding post-intall-1 step" | systemd-cat -t "autoinstall"
mv /usr/bin/post-install-1.sh /usr/bin/post-install.sh

echo "Rebooting" | systemd-cat -t "autoinstall"
reboot
