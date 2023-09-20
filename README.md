## Steps

1. Build docker
2. Build ISO

## Build docker

```bash
docker build -t bb8 ./docker/
```

## Build ISO

```bash
./build.sh
```

## ISO Customization

Use these files to customize the installation

- build.sh: Adds custom files to the customfolder then builds the ISO
- chroot_cmds_custom: used to install/download packages to the ISO
- post_install.sh: used to run commands post ISO installation
