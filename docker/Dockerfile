FROM ubuntu:22.04

ARG UID=1000
ARG GID=1000

RUN sed -i 's/archive.ubuntu.com/dk.archive.ubuntu.com/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
        p7zip-full wget xorriso \
        squashfs-tools 

RUN groupadd -r autoinstall -g $GID && \
    useradd -u $UID -r -g autoinstall -s /bin/bash -c "autoinstall user" autoinstall

WORKDIR /build
