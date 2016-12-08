#!/bin/bash
prefix="cloud_labs"
suffix=`ip a show eth0 | grep ether | awk '{print $2}' | sed -e s/://g`
location="japanwest"
vnet_addr="10.153.0.0/16"
snet_addr="10.153.1.0/24"

create_first(){
	rg_name=rg_${prefix}
	vnet_name=vnet_${prefix}
	snet_name=snet_${pfefix}
	sa_name=${prefix}${suffix}
	nsg_name=nsg_${prefix}
	
	ssh-keygen -t rsa -f ./${prefix} -P ""
	chmod 600 ./${prefix}*
	
	azure group create -n rg_raconxx -l japanwest
	azure network vnet create -g rg_raconxx -n vnet_raconxx -a 10.153.0.0/16 -l japanwest
	azure network vnet subnet create -g rg_raconxx --vnet-name vnet_raconxx -n snet_raconxx -a 10.153.1.0/24
	azure network public-ip create -g rg_raconxx -n ip_vm1 --location japanwest
	
	azure network nsg create -g TestRG -l westus -n NSG-FrontEnd
	azure network nsg rule create -g <RGNAME> -a <NSGNAME> -n <NSGRULENAME>  --source-port-range '*'  --destination-port-range 22 --access Allow
	
	azure storage account create <SANAME> --type LRS -g <RGNAME> -l <LOCNAME>
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

}

delete(){
	name=$1
}


ssh(){
name=$1

if [ "$2" != "" ]; then
	if [ "$3" != "" ]; then
		if [ "$4" != "" ]; then
			gcloud compute ssh $name --ssh-flag="-g" --ssh-flag="-L $2:$3:$4"
		else
			gcloud compute ssh $name --ssh-flag="-g" --ssh-flag="-L $2:127.0.0.1:$3"	
		fi
	else
		gcloud compute ssh $name --ssh-flag="-g" --ssh-flag="-L $2:127.0.0.1:$2"
	fi
else
	gcloud compute ssh $name
fi


}

delete(){
name=$1
}


case "$1" in
  "create_first" ) shift;create_first $*;;
  "ssh" ) shift;ssh $*;;
  "reset_password" ) shift;reset_password $*;;
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
