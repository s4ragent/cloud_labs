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

adminuser="azureuser"

get_External_IP(){
	name=$1
	ip_name=ip_${name}
	External_IP=`az vm show -g $rg_name -n $name -d | grep publicIps | awk -F '"' '{print $4}'`
	
	echo $External_IP
}

get_Internal_IP(){
	name=$1
	Internal_IP=`az vm show -g $rg_name -n $name -d | grep privateIps | awk -F '"' '{print $4}'`

	echo $Internal_IP
}


create_first(){

	
	ssh-keygen -t rsa -f ./${prefix} -P ""
	chmod 600 ./${prefix}*
	
	az group create -n $rg_name -l $location

	#az storage account create -n ${sa_name} --sku Standard_LRS --kind Storage -g $rg_name -l $location

	az network vnet create -g $rg_name -n $vnet_name --address-prefix $vnet_addr --subnet-name $snet_name --subnet-prefix $snet_addr

	az network nsg create -g $rg_name -l $location -n $nsg_name
	
	az network nsg rule create --resource-group $rg_name --nsg-name $nsg_name --name RuleSSH --protocol tcp --direction inbound --priority 1000 --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 22 --access allow

	az network vnet subnet update --resource-group $rg_name --vnet-name $vnet_name --name $snet_name --network-security-group $nsg_name

	
}

create_parts(){
	name=$1


}

create_linux(){
	name=$1
	vmsize=$2
	disksize=$3
	image_urn=$4
	
	#az network public-ip create -g $rg_name  -n ip_${name} --location $location
		
	az vm create --resource-group $rg_name --name $name --image $image_urn --admin-username $adminuser --size $vmsize --data-disk-sizes-gb $disksize --ssh-key-value ./${prefix}.pub --public-ip-address ip_${name} --vnet-name $vnet_name --subnet $snet_name --storage-sku Standard_LRS
	
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
	name=$1
	vmsize=$2
	disksize=$3
	create_linux $name $vmsize $disksize $image_urn	
}

create_ubuntu(){
	image_urn="canonical:ubuntuserver:16.04.0-LTS:latest"
	name=$1
	vmsize=$2
	disksize=$3
	create_linux $name $vmsize $disksize $image_urn	
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
	az group delete -n $rg_name -y
	rm -rf ./${prefix}*
}

delete(){
	name=$1
	az vm delete  -g $rg_name -n $name -y
	az network nic delete -g $rg_name -n ${name}VMNic
	az network public-ip delete -g $rg_name  -n ip_${name}
}

stop(){
	name=$1
	az vm deallocate -g $rg_name -n $name
}

start(){
	name=$1
	az vm start -g $rg_name -n $name
}

ssh2(){
name=$1
pip=`get_External_IP $name`


if [ "$2" != "" ]; then
	if [ "$3" != "" ]; then
		if [ "$4" != "" ]; then
			ssh  -o ServerAliveInterval=30 -i ./${prefix} -l $adminuser -g -L $2:$3:$4 $pip  
		else
			ssh  -o ServerAliveInterval=30 -i ./${prefix} -l $adminuser -g-L $2:127.0.0.1:$3 $pip	
		fi
	else
		ssh  -o ServerAliveInterval=30 -i ./${prefix} -l $adminuser -g -L $2:127.0.0.1:$2 $pip
	fi
else
	ssh  -o ServerAliveInterval=30 -i ./${prefix} -l $adminuser $pip
fi

}

resize()
{
	name=$1
	vmsize=$2
	az vm resize --resource-group $rg_name --name $name --size $vmsize
}

listsize()
{
	az vm list-sizes --location $location --output table
}

case "$1" in
  "create_first" ) shift;create_first $*;;
  "ssh2" ) shift;ssh2 $*;;
  "listsize" ) shift;listsize $*;;
  "resize" ) shift;resize $*;;
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
  "start" ) shift;start $*;;
  "get_External_IP" ) shift;get_External_IP $*;;
  "get_Internal_IP" ) shift;get_Internal_IP $*;;
esac
