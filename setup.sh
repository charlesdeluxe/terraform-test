#!/bin/bash
sudo apt-get update -y
sudo apt-get install nginx awscli -y
# demonstrate we can get a file from private s3 bucket
# TODO can probably use interpolation here for the s3 bucket
sudo aws s3 --region us-west-2 cp s3://hipc3u7pmjdg3ojq1/index.html /usr/share/nginx/html/index.html
