#!/bin/bash

mkdir -p ubuntu22 && \
    cd ubuntu22 &&
    rm -rf source-files && \
    mkdir -p source-files && \
    if [ ! -f jammy-live-server-amd64.iso ]; then wget https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/jammy-live-server-amd64.iso; fi && \
    7z -y x jammy-live-server-amd64.iso -osource-files && \
    rm -rf BOOT && \
    mv "source-files/[BOOT]" BOOT && \
    cp ../ubuntu22-grub-efi.cfg source-files/boot/grub/grub.cfg && \
    mkdir -p source-files/server && \
    touch source-files/server/meta-data && \
    cp ../ubuntu22-user-data source-files/server/user-data && \
    cd source-files && \
    xorriso -as mkisofs -r \
        -V '(Ubuntu 22.04 LTS)(EFIBIOS)' \
        -o /tmp/ubuntu-22.04-autoinstall.iso \
        --grub2-mbr ../BOOT/1-Boot-NoEmul.img \
        -partition_offset 16 \
        --mbr-force-bootable \
        -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \
        -appended_part_as_gpt \
        -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
        -c '/boot.catalog' \
        -b '/boot/grub/i386-pc/eltorito.img' \
        -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
        -eltorito-alt-boot \
        -e '--interval:appended_partition_2:::' \
        -no-emul-boot \
        .
