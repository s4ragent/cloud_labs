
# Setting
USERNAME="<api username>"  # ConoHa API access Account
PASSWORD="<api password>"
TENANT="<your tenant id>"


ACCOUNT_SERVICE="https://identity.tyo1.conoha.io/" # TODO : リージョン指定にしてここは自動取得したい。とりあえずはリージョンに合った identity API の URL をここに指定すれば動くはず。
TC_FLAVOR="g-1gb"  # VM Plan (この場合1GBプラン)
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

#$1 image_name
delete_image(){
  image_id=$(get_image $1)
  delete_resp=$(curl -i -X DELETE -H "Accept: application/json" -H "X-Auth-Token: $token" "$image_service/v2/images/$image_id" )
}


case "$1" in
  "delete_image" ) shift;delete_image $*;;
esac
