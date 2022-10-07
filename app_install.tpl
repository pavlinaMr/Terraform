#!/bin/bash

sudo amazon-linux-extras install php7.2 -y
sudo yum install httpd mysql -y
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo mv wordpress /var/www/html
sudo chown -R apache: /var/www/html/wordpress
sudo systemctl enable httpd --now
