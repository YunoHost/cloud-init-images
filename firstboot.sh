#!/bin/bash
rm -f /etc/resolv.conf
echo 'nameserver 89.234.141.66' > /etc/resolv.conf
echo 'nameserver 185.233.100.100' >> /etc/resolv.conf
echo 'nameserver 2a0c:e300::101' >> /etc/resolv.conf
echo 'nameserver 2001:910:800::40' >> /etc/resolv.conf
