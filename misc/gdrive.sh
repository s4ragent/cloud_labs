#/bin/bash
setup (){
curl -JLO https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download 
chmod +x gdrive-linux-x64
./gdrive-linux-x64 list
}

download(){
name=$1
id=$(./gdrive-linux-x64 list -q 'name contains '"'$name'"'' | awk '{print $1}' | tail -n 1)
./gdrive-linux-x64 download $id
}

case "$1" in
  "setup" ) shift;setup $*;;
  "download" ) shift;download $*;;
esac
