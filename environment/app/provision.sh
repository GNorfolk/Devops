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

# add user and group

sudo adduser --disabled-password --gecos "" app
sudo chown -R app:app /home/ubuntu/app