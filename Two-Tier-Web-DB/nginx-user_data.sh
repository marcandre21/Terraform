#!/bin/bash
sudo dnf update #Install latest update
sudo dnf install -y nginx #Install nginx
sudo systemctl start nginx.service #Start nginx server
sudo systemctl status nginx.service #Check server status
sudo systemctl enable nginx.service #Enable auto server start on reboot