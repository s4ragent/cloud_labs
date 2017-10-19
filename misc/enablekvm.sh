#!/bin/bash
yum -y install libguestfs libvirt libvirt-client python-virtinst qemu-kvm virt-manager virt-top virt-viewer virt-who virt-install bridge-utils 
systemctl start libvirtd
systemctl enable libvirtd