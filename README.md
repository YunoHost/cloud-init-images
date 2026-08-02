# cloud-init-images
Build cloudinit images for YunoHost

```bash
apt install libguestfs-tools
bash ./auto-build.sh
```

Follow the logs with this command:

```bash
virt-tail -a yunohost-12.qcow2 /tmp/builder.log
```
