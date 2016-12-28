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

adminuser="ops"

get_External_IP(){
	name=$1
	ip_name=ip_${name}
	External_IP=`azure network public-ip show -g $rg_name -n $ip_name | grep "IP Address" | awk '{print $5}'`
	
	echo $External_IP
}

get_Internal_IP(){
	name=$1
	nic_name=nic_${name}
	Internal_IP=`azure network nic show -g $rg_name -n $nic_name | grep "Private IP Address" | awk '{print $5}'`

	echo $Internal_IP
}


create_first(){

	
	ssh-keygen -t rsa -f ./${prefix} -P ""
	chmod 600 ./${prefix}*
	
	azure group create -n $rg_name -l $location

	azure storage account create ${sa_name} --sku-name LRS --kind Storage -g $rg_name -l $location

	azure network vnet create -g $rg_name -n $vnet_name -a $vnet_addr -l $location
	azure network vnet subnet create -g $rg_name --vnet-name $vnet_name -n $snet_name -a $snet_addr

	azure network nsg create -g $rg_name -l $location -n $nsg_name
	azure network nsg rule create -g $rg_name -a $nsg_name -n ssh-rule -c Allow -p Tcp -r Inbound -y 100 -f Internet -o '*' -e '*' -u 22
	azure network vnet subnet set -g $rg_name -e $vnet_name -o $nsg_name -n $snet_name
	
	
	
	
	
}

create_parts(){
	name=$1

	azure network public-ip create -g $rg_name  -n ip_${name} --location $location
}

create_linux(){
	name=$1
	vmsize=$2
	disksize=$3
	image_urn=$4
	
	create_parts $name
	
	azure vm create -g $rg_name -n $name --nic-name nic_${name} -i ip_${name} -o ${name}${sa_name} -x data-${name} -e $disksize --location $location --os-type Linux --image-urn $image_urn --admin-username $adminuser --vm-size $vmsize --ssh-publickey-file ./${prefix}.pub --vnet-name $vnet_name --vnet-subnet-name $snet_name
}

create_centos(){
	image_urn="OpenLogic:CentOS:7.2:latest"
	name=$1
	vmsize=$2
	disksize=$3
	create_linux $name $vmsize $disksize $image_urn	
}

create_oraclelinux(){
	image_urn="Oracle:Oracle-Linux:7.2:latest"

}

create_ubuntu(){
	image_urn="canonical:ubuntuserver:16.04.0-LTS:latest"
		name=$1
}

create_oraclelinux_docker(){
		name=$1
}

create_2012(){
		name=$1
}

create_centos_docker(){
		name=$1
}

create_ubuntu_docker(){
		name=$1
}

deleteall(){
	azure group delete -n $rg_name  -q
	rm -rf ./${prefix}*
}

delete(){
	name=$1
	azure vm delete  -g $rg_name -n $name -q
	azure network nic delete -g $rg_name -n nic_${name} -q
	azure network public-ip delete -g $rg_name  -n ip_${name} -q
	azure storage account delete -g $rg_name -q ${name}${sa_name}
}

stop(){
	name=$1
	azure vm deallocate -g $rg_name -n $name
}

ssh2(){
name=$1
pip=`get_External_IP $name`


if [ "$2" != "" ]; then
	if [ "$3" != "" ]; then
		if [ "$4" != "" ]; then
			ssh -i ./${prefix} -l $adminuser -g -L $2:$3:$4 $pip  
		else
			ssh -i ./${prefix} -l $adminuser -g-L $2:127.0.0.1:$3 $pip	
		fi
	else
		ssh -i ./${prefix} -l $adminuser -g -L $2:127.0.0.1:$2 $pip
	fi
else
	ssh -i ./${prefix} -l $adminuser $pip
fi

}


case "$1" in
  "create_first" ) shift;create_first $*;;
  "ssh2" ) shift;ssh2 $*;;
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
  "stop" ) shift;stop $*;;
  "get_External_IP" ) shift;get_External_IP $*;;
esac
