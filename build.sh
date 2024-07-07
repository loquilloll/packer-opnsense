#!/bin/bash




# Remove box from vagrant
# vagrant box remove loquilloll/opnsense --all 

# Remove box from virt-manager store
# VOLUME=$(sudo virsh vol-list default | grep loquilloll-VAGRANTSLASH-opnsense | awk '{print $1}')
# sudo virsh vol-delete --pool default $VOLUME

# Build box
packer build opnsense.json.pkr.hcl

# Add new box to vagrant
# vagrant box add output/opnsense.box --name loquilloll/opnsense

# Publish to vagrant cloud
vagrant cloud publish loquilloll/opnsense 1.0.0 libvirt output/opnsense.box --release --force