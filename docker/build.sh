#!/bin/bash

docker build -t ubuntu-autoinstall -f ./docker/Dockerfile ./docker
docker run \
    -e "TERM=xterm-256color" \
    -v "$(pwd):/home/build" \
    --privileged \
    -ti ubuntu-autoinstall \
    /bin/bash -c "cd /home/build && ./mk_custom_iso.sh ${1}"
