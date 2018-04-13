#!/bin/bash
sudo apt-get update -y
sudo apt-get install nginx awscli -y
sudo aws s3 --region us-west-2 cp s3://hipc3u7pmjdg3ojq3/index.html /usr/share/nginx/html/index.html
