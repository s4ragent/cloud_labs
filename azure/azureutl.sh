#!/bin/bash
prefix="cloud_labs"
suffix=`ip a show eth0 | grep ether | awk '{print $2}' | sed -e s/://g`

create_rg_storage_vnet(){
	rg_name=rg_${prefix}
	vnet_name=vnet_${prefix}
	snet_name=snet_${pfefix}
	sa_name=${prefix}${suffix}
	nsg_name=nsg_${prefix}
	
	
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
  "create_rg_first" ) shift;create_first $*;;
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
