#!/bin/bash
if [ ! -e  /root/rac_on_xx ]; then
   if [ -e /etc/debian_version ]; then
	apt-get update
	apt-get install -y git python-dev python-pip libssl-dev unzip bridge-utils yum systemd-container
   elif [ -e /etc/redhat-release ]; then
      sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
      yum clean all
	yum install -y epel-release
	yum install -y python-pip openssl-devel gcc python-devel git unzip bridge-utils --enablerepo=epel
   fi
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
