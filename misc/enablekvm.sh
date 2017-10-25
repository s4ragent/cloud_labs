#!/bin/bash



#!/bin/bash
if [ ! -e  /root/rac_on_xx ]; then
   if [ -e /etc/debian_version ]; then
      apt-get update
      apt-get install -y git screen qemu-utils python-dev python-pip libssl-dev unzip
      apt-get install -y kvm virt-manager libvirt-bin bridge-utils
      systemctl start libvirt-bin
      systemctl enable libvirt-bin
   elif [ -e /etc/redhat-release ]; then
      sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
      yum clean all
      yum -y install git screen qemu-img epel-release
      yum -y install python-pip openssl-devel gcc python-devel git unzip --enablerepo=epel 
      systemctl start libvirtd
      systemctl enable libvirtd
   fi
   git clone https://github.com/s4ragent/rac_on_xx /root/rac_on_xx
   git clone https://github.com/s4ragent/cloud_labs /root/cloud_labs
   pip install pip --upgrade
   pip install ansible
fi

HasSwap=`free | grep Swap | awk '{print $2}'`
if [ "$HasSwap" = "0" ]; then
	dd if=/dev/zero of=/var/tmp/swap.img bs=1M count=8192
	mkswap /var/tmp/swap.img
	sh -c 'echo "/var/tmp/swap.img swap swap defaults 0 0" >> /etc/fstab'
	swapon -a
fi

