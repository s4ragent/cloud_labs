#!/bin/bash
prefix="cloudlabs"
suffix=`ip a show eth0 | grep ether | awk '{print $2}' | sed -e s/://g`
location="japanwest"
vnet_addr="10.153.0.0/16"
snet_addr="10.153.1.0/24"

rg_name=rg_${prefix}
vnet_name=vnet_${prefix}
snet_name=snet_${prefix}
sa_name=${prefix}${suffix}
nsg_name=nsg_${prefix}


create_first(){

	
	ssh-keygen -t rsa -f ./${prefix} -P ""
	chmod 600 ./${prefix}*
	
	azure group create -n $rg_name -l $location
	azure network vnet create -g $rg_name -n $vnet_name -a $vnet_addr -l $location
	azure network vnet subnet create -g $rg_name --vnet-name $vnet_name -n $snet_name -a $snet_addr

	azure network nsg create -g $rg_name -l $location -n $nsg_name
	azure network nsg rule create -g $rg_name -a $nsg_name -n ssh-rule -c Allow -p Tcp -r Inbound -y 100 -f Internet -o * -e * -u 22
	azure network nsg rule create -g $rg_name -a $nsg_name -n inner-rule -c Allow -p * -r Inbound -y 200 -f $vnet_addr -o * -e $vnet_addr -u *
	
	
	azure storage account create $sa_name --type LRS -g $rg_name -l $location
}

create_parts(){
	name=$1
	azure network public-ip create -g $rg_name  -n ip_${name} --location $location
}

create_centos(){
		name=$1
}

create_oraclelinux(){
		name=$1
}

create_2012(){
		name=$1
}

create_ubuntu(){
		name=$1
}

create_oraclelinux_docker(){
		name=$1
}

create_centos_docker(){
		name=$1
}

create_ubuntu_docker(){
		name=$1
}

deleteall(){
	azure group delete -n $rg_name -l $location -q 
}

delete(){
	name=$1
}


ssh(){
}

delete(){
name=$1
}


case "$1" in
  "create_first" ) shift;create_first $*;;
  "ssh" ) shift;ssh $*;;
  "create_2012" ) shift;create_2012 $*;;
  "create_2016" ) shift;create_2016 $*;;
  "create_oraclelinux" ) shift;create_oraclelinux $*;;
  "create_centos" ) shift;create_centos $*;;
  "create_ubuntu" ) shift;create_ubuntu $*;;
  "create_centos_docker" ) shift;create_centos_docker $*;;
  "create_ubuntu_docker" ) shift;create_ubuntu_docker $*;;
  "create_oraclelinux_docker" ) shift;create_oraclelinux_docker $*;;
  "deleteall" ) shift;deleteall $*;;
  "delete" ) shift;delete $*;;
esac
