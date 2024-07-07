#!/bin/bash




# Remove box from vagrant
vagrant box remove loquilloll/opnsense --all 
# Remove box from virt-manager store
sudo virsh vol-delete --pool default loquilloll-VAGRANTSLASH-opnsense_vagrant_box_image_0_1720319777_box_0.img
# Build box
packer build opnsense.json.pkr.hcl
# Add new box to vagrant
vagrant box add output/opnsense.box --name loquilloll/opnsense