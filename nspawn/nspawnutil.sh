#/bin/bash

container=rac

ansible_ssh_private_key_file=cloud_labs

		ssh-keygen -t rsa -P "" -f $ansible_ssh_private_key_file
		chmod 600 ${ansible_ssh_private_key_file}*


mkdir -p /var/lib/machines/$container/etc/yum.repos.d/

curl -L -o /var/lib/machines/$container/etc/yum.repos.d/public-yum-ol7.repo http://yum.oracle.com/public-yum-ol7.repo

yum -c /var/lib/machines/$container/etc/yum.repos.d/public-yum-ol7.repo -y --nogpg --installroot=/var/lib/machines/$container install systemd openssh openssh-server passwd yum sudo oraclelinux-release vim-minimal iproute initscripts

touch /var/lib/machines/$container/etc/sysconfig/network


cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
IPADDR=172.64.0.1
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=static
NM_CONTROLLED=no
DELAY=0
EOF