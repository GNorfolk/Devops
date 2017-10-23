#!/bin/bash

# update the sources list and upgrade any existing packages
sudo apt-get update -y
sudo apt-get upgrade -y

# install nginx
sudo apt-get install nginx -y

# install correct version of node.js
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

# install pm2 with npm
sudo npm install pm2 -g

# add user and give app ownership
sudo adduser --disabled-password --gecos "" app
sudo chown -R app:ubuntu /home/ubuntu/app

# change app folder permissions
sudo chmod 570 app

# proxy port 80 to direct to 3000
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /home/ubuntu/Devops/environment home/ubuntu/environment
sudo cp /home/ubuntu/environment/app/reverse-proxy.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
sudo service nginx configtest
sudo service nginx restart