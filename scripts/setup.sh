#!/bin/bash
sudo apt-get update -y
sudo apt-get install nginx awscli -y
# demonstrate we can get a file from private s3 bucket
sudo aws s3 cp s3://hipc3u7pmjdg3ojq/index.html /var/www/html/index.html