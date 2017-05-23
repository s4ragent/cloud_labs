#/bin/bash
curl -JLO https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download 
chmod +x gdrive-linux-x64
./gdrive-linux-x64 list

id1=$(./gdrive-linux-x64 list -q 'name contains "V840012-01.zip" ' | awk '{print $1}' | tail -n 1)
id1=$(./gdrive-linux-x64 list -q 'name contains "V839960-01.zip" ' | awk '{print $1}' | tail -n 1)

./gdrive-linux-x64 download $id1
./gdrive-linux-x64 download $id2
