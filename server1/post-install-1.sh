#!/bin/bash

echo "Continuing system customization" | systemd-cat -t "autoinstall"

echo "tailscale install" | systemd-cat -t "autoinstall"
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
apt-get update
apt-get -yyqq install tailscale

echo "Home Assistant install" | systemd-cat -t "autoinstall"
apt-get -yyqq install docker.io
USERDIR=/home/$(getent passwd 1000 | cut -f 1 -d :)
mkdir -p ${USERDIR}/.config/homeassistant
docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=America/Sao_Paulo \
  -v ${USERDIR}/.config/homeassistant:/config \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable

echo "Removing this script from systemd" | systemd-cat -t "autoinstall"
systemctl disable post-install.service
rm /usr/lib/systemd/system/post-install.service
rm /usr/bin/post-install.sh

echo "Restoring issue message" | systemd-cat -t "autoinstall"
mv /etc/issue_ /etc/issue
echo "Done! Rebooting" | systemd-cat -t "autoinstall"
reboot
