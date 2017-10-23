#!/bin/bash
ZONE="us-central1-c"
#n1-highmem-4 4vcpu	26 GB
#g1-small	    1	vcpu  1.70

get_console(){
name=$1
gcloud compute instances get-serial-port-output $name
}

reset_password(){
	gcloud compute reset-windows-password $1
}

creategcedisk(){
	gcloud compute disks create "$1" --size $2 --type "pd-ssd"
}

#1 name $2 machine type $3 disksize $4 preemptible
#ex create_centos centos n1-highmem-4 200 preemptible
#ex create_centos centos g1-small 20 preemptible
create_centos(){
		IMAGE_OPS="--image-family=centos-7 --image-project=centos-cloud"
		
		name=$1	
		if [ "$4" = "preemptible" ]; then
  		OPS="--preemptible --maintenance-policy TERMINATE"
  	else
  		OPS="	--maintenance-policy MIGRATE"
		fi
		
		gcloud compute instances create $name --machine-type $2 --network "default" --can-ip-forward $OPS --scopes "https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write" $IMAGE_OPS --boot-disk-type "pd-ssd" --boot-disk-device-name $name --boot-disk-size $3 --zone $ZONE
}

# 4cpu 26GB
#ex create_nested centos n1-highmem-4 200 preemptible
create_nested(){
	name=$1
		IMAGE_OPS="--image nested-${name}"
		
		if [ "$4" = "preemptible" ]; then
  		OPS="--preemptible --maintenance-policy TERMINATE"
  	else
  		OPS="	--maintenance-policy MIGRATE"
		fi
		
		gcloud compute instances create $name --machine-type $2 --network "default" --can-ip-forward $OPS --scopes "https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write" $IMAGE_OPS --boot-disk-type "pd-ssd" --boot-disk-device-name $name --boot-disk-size $3 --zone $ZONE
}

create_ubuntu(){
		name=$1
		gcloud compute instances create $name --machine-type $2 --network "default" --can-ip-forward --maintenance-policy "MIGRATE" --scopes "https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write" --image-family "/ubuntu-os-cloud/ubuntu-1604-lts" --boot-disk-type "pd-ssd" --boot-disk-device-name $name --boot-disk-size $3
}

#$1 exists vm name
create_image(){
		name=$1
		gcloud compute disks snapshot $name --snapshot-names snapshot-${name} --zone $ZONE
		
		gcloud compute disks create disk-temp-${name} --source-snapshot snapshot-${name} --zone $ZONE

		gcloud compute snapshots delete --quiet snapshot-${name}

  gcloud compute images create nested-${name} --source-disk disk-temp-${name} --source-disk-zone $ZONE --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

gcloud compute disks delete --quiet disk-temp-${name}   --zone ${ZONE}

}

delete_image(){
		name=$1
gcloud compute images delete nested-${name}
}

ssh(){
name=$1

if [ "$2" != "" ]; then
	if [ "$3" != "" ]; then
		if [ "$4" != "" ]; then
			gcloud compute ssh $name --ssh-flag="-g" --ssh-flag="-L $2:$3:$4" --zone ${ZONE}
		else
			gcloud compute ssh $name --ssh-flag="-g" --ssh-flag="-L $2:127.0.0.1:$3"	 --zone ${ZONE}
		fi
	else
		gcloud compute ssh $name --ssh-flag="-g" --ssh-flag="-L $2:127.0.0.1:$2" --zone ${ZONE}
	fi
else
	gcloud compute ssh $name --zone ${ZONE}
fi


}

delete(){
name=$1
gcloud compute instances delete $name --zone ${ZONE}
}
#n1-standard-1 1cpu	3.75GB 	$7.30
#n1-standard-2 2cpu 7.5GB  $14.60
#n1-standard-4 4cpu 15GB   $29.20
#n1-standard-8	8	cpu 30GB   $58.40
#n1-highmem-2	 2cpu	 13GB	  	$18.25
#n1-highmem-4	 4	cpu 26GB   $36.50
#n1-highmem-8	8	cpu  52GB	   $73
change_size(){
name=$1
gcloud compute instances set-machine-type $name --machine-type=$2 --zone ${ZONE}
}

change_size2(){
name=$1
gcloud compute instances set-machine-type $name --custom-cpu=$2 --custom-memory=$3 --zone ${ZONE}
}

stop(){
name=$1
gcloud compute instances stop $name --zone ${ZONE}
}

start(){
name=$1
gcloud compute instances start $name --zone ${ZONE}
}

case "$1" in
  "ssh" ) shift;ssh $*;;
  "reset_password" ) shift;reset_password $*;;
  "create_2012" ) shift;create_2012 $*;;
  "create_image" ) shift;create_image $*;;
  "delete_image" ) shift;delete_image $*;;
  "create_rhel6" ) shift;create_rhel6 $*;;
  "create_centos" ) shift;create_centos $*;;
  "create_nested" ) shift;create_nested $*;;
  "create_ubuntu" ) shift;create_ubuntu $*;;
  "create_centos_docker" ) shift;create_centos_docker $*;;
  "create_ubuntu_docker" ) shift;create_ubuntu_docker $*;;
  "deleteandstart" ) shift;deleteandstart $*;; 
  "get_console" ) shift;get_console $*;;  
  "deleteall" ) shift;deleteall $*;;
  "start" ) shift;start $*;;
  "stop" ) shift;stop $*;;
  "change_size" ) shift;change_size $*;;
  "change_size2" ) shift;change_size2 $*;;
  "delete" ) shift;delete $*;;
  "creategcedisk" ) shift;creategcedisk $*;;
  "creategceinstance" ) shift;creategceinstance $*;;
esac
