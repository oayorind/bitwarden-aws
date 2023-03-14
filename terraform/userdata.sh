#!/bin/bash

# Userdata script to run on EC2 instance for initial configuration.
# Review the /var/log/cloud-init-output.log to see the results of the commands.

# Configure Machine Hostname
sudo hostnamectl set-hostname bitwarden
sudo sed -i '/127.0.0.1 localhost/a 127.0.0.1 bitwarden' /etc/cloud/templates/hosts.debian.tmpl
sudo sed -i '/127.0.0.1 localhost/a 127.0.0.1 bitwarden' /etc/hosts

# Configure Date/Time
sudo timedatectl set-timezone America/Toronto

# Install Prerequisites
sudo apt update
sudo apt -y upgrade
sudo apt install -y ca-certificates curl gnupg lsb-release vim software-properties-common

# Install Ansible
sudo apt install -y ansible

# Install Docker Packages
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Format and mount EBS Volume /dev/sdb1 to /opt
# Obtain the UUID and add a static mount in /etc/fstab for persistence after reboot
sudo mkfs -t ext4 /dev/sdb
sudo mkdir /opt/bitwarden
sudo cp /etc/fstab /etc/fstab.orig
sudo echo UUID=$(sudo blkid /dev/sdb | sed 's/[^"]*"\([^"]*\)".*/\1/') /opt/bitwarden ext4 defaults,nofail 0 2 | sudo tee -a /etc/fstab > /dev/null
sudo mount /dev/sdb

# Create and configure bitwarden user as per install doc:  https://bitwarden.com/help/install-on-premise-linux/
# Not setting a password for the user is intentional at this point, can be done by admin later
# The /opt/bitwarden directory is already created and mounted

sudo adduser --home /home/bitwarden --disabled-password --gecos "" --shell /bin/bash bitwarden
sudo groupadd docker
sudo usermod -aG docker bitwarden
sudo chmod -R 700 /opt/bitwarden
sudo chown -R bitwarden:bitwarden /opt/bitwarden

## Download Bitwarden
curl -Lso /opt/bitwarden/bitwarden.sh https://go.btwrdn.co/bw-sh && chmod 700 /opt/bitwarden/bitwarden.sh
sudo chmod 700 /opt/bitwarden/bitwarden.sh
sudo chown bitwarden:bitwarden /opt/bitwarden/bitwarden.sh

