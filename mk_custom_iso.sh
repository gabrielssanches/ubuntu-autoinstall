#!/bin/bash


systemd_wait_online_timeout() {
    mkdir -p edit/etc/systemd/system/systemd-networkd-wait-online.service.d
    cat <<EOF >> edit/etc/systemd/system/systemd-networkd-wait-online.service.d/timeout.conf
[Service]
ExecStart=
ExecStart=/lib/systemd/systemd-networkd-wait-online --timeout=1
EOF
}

chroot_script_create() {
    cat <<EOF >> edit/chroot_script.sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
sed -i 's/archive.ubuntu.com/dk.archive.ubuntu.com/g' /etc/apt/sources.list
EOF
    cat ../${1}/chroot_cmds >> edit/chroot_script.sh
    if [ -f ../${1}/chroot_cmds ]; then
        echo "Adding custom chroot cmds from ../${1}/chroot_cmds"
        cat ../${1}/chroot_cmds >> edit/chroot_script.sh
    fi
    cat <<EOF >> edit/chroot_script.sh
umount /proc
umount /sys
umount /dev/pts
EOF
    chmod 777 edit/chroot_script.sh
}

patch_ubuntu_installer() {
    unsquashfs source-files/casper/ubuntu-server-minimal.squashfs && \
    mv squashfs-root edit && \
    mount -o bind /run/ edit/run && \
    mkdir -p edit/dev && \
    mount --bind /dev/ edit/dev && \
    chroot_script_create ${1} && \
    systemd_wait_online_timeout && \
    mkdir -p edit/opt/autoinstall && \
    cp ../${1}/apt-install-cache.service edit/opt/autoinstall && \
    cp ../${1}/apt-install-cache.sh edit/opt/autoinstall && \
    mkdir -p edit/customfolder && \
    cp -rl ../${1}/customfolder/* edit/customfolder && \
    chmod -R +r edit/customfolder && \
    chmod +x edit/chroot_script.sh && \
    mv edit/etc/resolv.conf . && \
    cp /etc/resolv.conf edit/etc && \
    chroot edit /bin/bash -c "su - -c /chroot_script.sh" && \
    mv resolv.conf edit/etc/resolv.conf && \
    umount edit/run && \
    umount edit/dev && \
    rm -r edit/dev && \
    chmod +w source-files/casper/ubuntu-server-minimal.manifest && \
    chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > source-files/casper/ubuntu-server-minimal.manifest && \
    rm source-files/casper/ubuntu-server-minimal.squashfs && \
    rm source-files/casper/ubuntu-server-minimal.squashfs.gpg && \
    mksquashfs edit source-files/casper/ubuntu-server-minimal.squashfs -comp xz && \
    printf "$(sudo du -sx --block-size=1 edit | cut -f1)" > source-files/casper/ubuntu-server-minimal.size 2>/dev/null && \
    rm -r edit
}

BUILDDIR=_build-ubuntu22-${1}
BUILDDIR_PATH=$(pwd)/_build-ubuntu22-${1}
echo "output dir ${BUILDDIR_PATH}"

rm -rf ${BUILDDIR} && \
    mkdir -p ${BUILDDIR} && \
    cd ${BUILDDIR} &&
    rm -rf source-files && \
    mkdir -p source-files && \
    if [ ! -f ../jammy-live-server-amd64.iso ]; then wget https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/jammy-live-server-amd64.iso -O ../jammy-live-server-amd64.iso; fi && \
    7z -y x ../jammy-live-server-amd64.iso -osource-files && \
    rm -rf BOOT && \
    mv "source-files/[BOOT]" BOOT && \
    cp ../${1}/grub-efi.cfg source-files/boot/grub/grub.cfg && \
    mkdir -p source-files/server && \
    touch source-files/server/meta-data && \
    cp ../${1}/user-data source-files/server/user-data && \
    patch_ubuntu_installer ${1} && \
    cd source-files && \
    rm -f ../../ubuntu-22.04-autoinstall.iso && \
    xorriso -as mkisofs -r \
        -V '(Ubuntu 22.04 LTS)(EFIBIOS)' \
        -o ${BUILDDIR_PATH}/ubuntu-22.04-autoinstall.iso \
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
        . && \
    ls -lh ..

#chown -R autoinstall:autoinstall ${BUILDDIR_PATH}
