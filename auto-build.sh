#!/usr/bin/env bash
set -Eeuo pipefail

suite=bookworm
suite_nb=12
arch=amd64

progress() {
    echo -e "\e[32m###### $*\e[0m"
}

progress "Downloading debian genericcloud image (with cloud-init inside)..."
IMAGE_URL=https://cloud.debian.org/images/cloud/${suite}/latest/debian-${suite_nb}-genericcloud-${arch}.qcow2
rm -f debian-${suite_nb}.qcow2
wget "$IMAGE_URL" -O debian-${suite_nb}.qcow2

progress "Growing image..."
cp debian-${suite_nb}.qcow2 yunohost-${suite_nb}.qcow2
qemu-img resize yunohost-${suite_nb}.qcow2 8G

progress "Customizing the image by running install script..."
virt-customize \
    -v \
    -a "yunohost-${suite_nb}.qcow2" \
    --hostname yunohost \
    --update \
    --install 'curl' \
    --upload './cloud.cfg:/etc/cloud/cloud.cfg' \
    --run-command "curl https://install.yunohost.org/${suite} | bash -s -- -a " \
    --firstboot ./firstboot.sh

progress "Reducing the image's size..."
virt-sparsify --in-place yunohost-${suite_nb}.qcow2

progress "Compressing the image..."
xz --keep --force --verbose yunohost-${suite_nb}.qcow2
