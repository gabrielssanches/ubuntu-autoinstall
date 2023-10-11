#!/bin/bash

echo "Running post installation commands" | systemd-cat -t "autoinstall"

exit 0
echo "Home Assistant install" | systemd-cat -t "autoinstall"

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
