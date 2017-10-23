#!/bin/bash

# # update the sources list and upgrade any existing packages
sudo apt-get update -y
sudo apt-get upgrade -y

# import MongoDB key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

# create MongoDB list file
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# update again
sudo apt-get update -y

# install MongoDB
sudo apt-get install -y mongodb-org

# copy service file into necessary place
sudo cp /home/ubuntu/environment/db/mongodb.service /etc/systemd/system/

# start up mongo service
sudo systemctl start mongodb

# copies mongod config file to /etc/ folder
sudo rm /etc/mongod.conf
sudo cp /home/ubuntu/environment/db/mongod.conf /etc/mongod.conf

# Resets mondo service
sudo service mongod restart