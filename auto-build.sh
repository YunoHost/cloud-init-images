#!/bin/bash

suite=bookworm
suite_nb=12

echo "Download debian genericcloud image (with cloud-init inside)"
rm -f debian-${suite_nb}.qcow2
wget https://cloud.debian.org/images/cloud/${suite}/latest/debian-${suite_nb}-genericcloud-amd64.qcow2 -0 debian-${suite_nb}.qcow2

echo "Grows image"
cp debian-${suite_nb}.qcow2 yunohost-${suite_nb}.qcow2
qemu-img resize yunohost-${suite_nb}.qcow2 8G

echo "Customize the image by running install script"
virt-customize -a yunohost-${suite_nb}.qcow2 --hostname yunohost --update --install 'curl' --upload './cloud.cfg:/etc/cloud/cloud.cfg' --run-command "curl https://install.yunohost.org/${suite} | bash -s -- -a -d testing"

echo "Reduce the image's size"
virt-sparsify --in-place yunohost-${suite_nb}.qcow2

echo "Compress"
#xz -v yunohost-${suite_nb}.qcow2
