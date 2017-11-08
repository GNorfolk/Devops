#!/bin/bash

cd /home/ubuntu/app

export DB_HOST=mongodb://${db_host_ip}/posts

pm2 start app.js