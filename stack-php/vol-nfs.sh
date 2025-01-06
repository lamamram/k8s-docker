#!/bin/bash
## pour réexécuter le script : sudo rm -rf /mnt/nfs-dir /etc/exports
# puis ./vol-nfs.sh
if [ -d "/mnt/nfs-dir" ]; then
  sudo rm -rf /mnt/nfs-dir && sudo rm -rf /etc/exports
fi

# conf "vanilla" pas prod !!!
sudo apt-get update
sudo apt-get install -y nfs-kernel-server
sudo mkdir -p /mnt/nfs-dir/{nginx-conf.d,app,initdb.d}
sudo cp ./vhost.conf /mnt/nfs-dir/nginx-conf.d
sudo cp ./index.php /mnt/nfs-dir/app
sudo cp ./mariadb-init.sql /mnt/nfs-dir/initdb.d
sudo chown -R nobody:nogroup /mnt/nfs-dir
find /mnt/nfs-dir -type d -print0 | sudo xargs -0 chmod 0755
find /mnt/nfs-dir -type f -print0 | sudo xargs -0 chmod 0644
echo "/mnt/nfs-dir *(rw,sync,no_subtree_check,no_all_squash)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
