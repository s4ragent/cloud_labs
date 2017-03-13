
# Setting
source ./env.sh


ACCOUNT_SERVICE="https://identity.tyo1.conoha.io/" # TODO : リージョン指定にしてここは自動取得したい。とりあえずはリージョンに合った identity API の URL をここに指定すれば動くはず。
FLAVOR="g-1gb"  # VM Plan (この場合1GBプラン)
APPLY_SECURITY_GROUP="gncs-ipv4-all"

ident_resp=$( curl -X POST -H "Accept: application/json" -d "{\"auth\":{\"passwordCredentials\":{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"},\"tenantId\":\"$TENANT\"}}" "$ACCOUNT_SERVICE/v2.0/tokens" ) 


token=$( echo $ident_resp | jq ".access.token.id" | sed "s/\"//g" )
image_service=$( echo $ident_resp | jq ".access.serviceCatalog[] | select(.type == \"image\") | .endpoints[0].publicURL" | sed "s/\"//g" )
compute_service=$( echo $ident_resp | jq ".access.serviceCatalog[] | select(.type == \"compute\") | .endpoints[0].publicURL" | sed "s/\"//g" )
network_service=$( echo $ident_resp | jq ".access.serviceCatalog[] | select(.type == \"network\") | .endpoints[0].publicURL" | sed "s/\"//g" )

#$1 image_name
get_image(){
  imagelist_resp=$( curl -X GET -H "Accept: application/json" -H "X-Auth-Token: $token" "$image_service/v2/images" )
  image_id=$( echo $imagelist_resp | jq ".images[] | select(.name == \"$1\") | .id" | sed "s/\"//g" )
  echo $image_id
}

list_image(){
  imagelist_resp=$( curl -X GET -H "Accept: application/json" -H "limit: 3" -H "owner: $TENANT" -H "X-Auth-Token: $token" "$image_service/v2/images" )
  echo $imagelist_resp | jq ".images[]"
}



#$1 image_name
delete_image(){
  image_id=$(get_image $1)
  delete_resp=$(curl -i -X DELETE -H "Accept: application/json" -H "X-Auth-Token: $token" "$image_service/v2/images/$image_id" )
}


#1 image_name
get_vm(){
  image_id=$(get_image $1)
  vmlist_resp=$(curl -X GET -H "Accept: application/json" -H "image: $1" -H "X-Auth-Token: $token" "$compute_service/servers")
  #vm_id=$( echo $vmlist_resp | jq ".servers.id" | head -n 1 | sed "s/\"//g" )
  vm_id=$( echo $vmlist_resp | jq ".servers[0].id"| sed "s/\"//g" )
  echo $vm_id
}

#$1 image_name
delete_vm(){
  vm_id=$(get_vm $1)
  delete_resp=$(curl -i -X DELETE -H "Accept: application/json" -H "X-Auth-Token: $token" "$compute_service/servers/$vm_id")
}

#$1 image_name
create_vm(){
  imagelist_resp=$( curl -X GET -H "Accept: application/json" -H "X-Auth-Token: $token" "$image_service/v2/images" )
  image_id=$( echo $imagelist_resp | jq ".images[] | select(.name == \"$1\") | .id" | sed "s/\"//g" )
  flavorlist_resp=$( curl -X GET -H "Accept: application/json" -H "X-Auth-Token: $token" "$compute_service/flavors/detail" )
  flavor_id=$( echo $flavorlist_resp | jq ".flavors[] | select(.name == \"$FLAVOR\") | .id" | sed "s/\"//g" )
  makevm_resp=$( curl -X POST -H "Accept: application/json" -H "X-Auth-Token: $token" -d "{\"server\": {\"imageRef\": \"$image_id\",\"flavorRef\": \"$flavor_id\",\"security_groups\":[{\"name\": \"default\"},{\"name\": \"$APPLY_SECURITY_GROUP\"}]}}" "$compute_service/servers" )
}

case "$1" in
  "delete_image" ) shift;delete_image $*;;
  "get_image" ) shift;get_image $*;;
  "list_image" ) shift;list_image $*;;
  "get_vm" ) shift;get_vm $*;;
  "create_vm" ) shift;create_vm $*;;
  "delete_vm" ) shift;delete_vm $*;;
esac
