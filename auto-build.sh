#!/usr/bin/env bash
set -Eeuo pipefail
set -x

suite=${1:-bookworm}
declare -A SUITE_NBS=(
    [bullseye]=11
    [bookworm]=12
    [trixie]=13
)
suite_nb="${SUITE_NBS[$suite]}"
arch=amd64

progress() {
    echo -e "\e[32m###### $*\e[0m"
}

progress "Downloading debian genericcloud image (with cloud-init inside)..."
IMAGE_URL=https://cloud.debian.org/images/cloud/${suite}/latest/debian-${suite_nb}-genericcloud-${arch}.qcow2
curl -L -o "debian-$suite_nb.qcow2" --time-cond "debian-$suite_nb.qcow2" --remote-time "$IMAGE_URL"

progress Downloading installer script...
INSTALLER_URL=https://install.yunohost.org/${suite}
curl -L -o "install-yunohost-$suite_nb" --time-cond "install-yunohost-$suite_nb" --remote-time "$INSTALLER_URL"
chmod +x "install-yunohost-$suite_nb"

progress "Growing image..."
cp "debian-${suite_nb}.qcow2" "yunohost-${suite_nb}.qcow2"
qemu-img resize "yunohost-${suite_nb}.qcow2" 8G

progress "Customizing the image by running install script..."
VIRT_CUSTOMIZE_OPTS=(
    -v
    -a "debian-$suite_nb.qcow2"
    --hostname yunohost
    --network
    --mkdir /etc/cloud
    --upload './cloud.cfg:/etc/cloud/cloud.cfg'
    --upload "./install-yunohost-$suite_nb:/tmp/install-yunohost-$suite_nb"
    --run-command "/tmp/install-yunohost-$suite_nb -a"
    --scrub "install-yunohost-$suite_nb -a"
    --firstboot ./firstboot.sh
)
virt-customize "${VIRT_CUSTOMIZE_OPTS[@]}"

progress "Reducing the image's size..."
virt-sparsify --in-place "yunohost-${suite_nb}.qcow2"

progress "Compressing the image..."
xz --keep --force --verbose "yunohost-${suite_nb}.qcow2"
