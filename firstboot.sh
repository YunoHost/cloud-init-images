#!/bin/bash
# Fix strange issue where the /etc/resolv.conf is a symlink onto /run/systemd.../resolv.conf
rm -f /etc/resolv.conf
cat << EOF > /etc/resolv.conf
nameserver 89.234.141.66
nameserver 185.233.100.100
nameserver 2a0c:e300::101
nameserver 2001:910:800::40
EOF
