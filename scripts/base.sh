#!/bin/sh
# Enable exit/failure on error.
set -eux

# Enable FRRouting. BGP,OSPF, RIP, etc.
pkg install -y os-frr

echo "upgrading opnsense"
opnsense-update

echo "cleanup"
opnsense-update -e

# shutdown -p now
#echo 'autoboot_delay="0"' >> /boot/loader.conf