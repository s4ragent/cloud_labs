#!/bin/bash
VBOXVERSION="5.1"
VAGRANTVERSION="2.0.0"

if [ ! -e  /root/rac_on_xx ]; then
   if [ -e /etc/debian_version ]; then
     apt-get update

					sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib non-free' > /etc/apt/sources.list.d/virtualbox.list"
					wget https://www.virtualbox.org/download/oracle_vbox.asc
					apt-key add oracle_vbox.asc

					apt-get install -y git virtualbox-${VBOXVERSION} git python-dev python-pip libssl-dev unzip
					wget https://releases.hashicorp.com/vagrant/$VAGRANTVERSION	/vagrant_${VAGRANTVERSION}_x86_64.deb

					dpkg --install vagrant_${VAGRANTVERSION}_x86_64.deb

					 
   elif [ -e /etc/redhat-release ]; then
      sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
      cd /etc/yum.repos.d
						wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
						yum clean all
						yum install -y epel-release 
						yum install -y binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
						yum install -y python-pip openssl-devel gcc python-devel git unzip Virtualbox-${VBOXVERSION} --enablerepo=epel
						yum -y install  https://releases.hashicorp.com/vagrant/${VAGRANTVERSION}/vagrant_${VAGRANTVERSION}_x86_64.rpm
   fi
   git clone https://github.com/s4ragent/rac_on_xx /root/rac_on_xx
   git clone https://github.com/s4ragent/cloud_labs /root/cloud_labs
fi

HasSwap=`free | grep Swap | awk '{print $2}'`
if [ "$HasSwap" = "0" ]; then
	dd if=/dev/zero of=/var/tmp/swap.img bs=1M count=4096
	mkswap /var/tmp/swap.img
	sh -c 'echo "/var/tmp/swap.img swap swap defaults 0 0" >> /etc/fstab'
	swapon -a
fi

pip install pip --upgrade
pip install ansible    

curl -sSL https://get.docker.com/ | sh                                                                                                 
systemctl enable docker                                                                                                                
systemctl start docker
