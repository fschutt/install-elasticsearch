#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then 
    echo "Please run this script as root"
    exit 1
fi

# Check if apt-transport-https is installed
if ! [[ -x "$(command -v apt-transport-https)" ]]; then
    sudo apt-get install apt-transport-https
fi

# FINGERPRINT="4609 5ACC 8548 582C 1A26 99A9 D27D 666C D88E 42B4"

# Download and install the public signing key:
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Save the repository definition to /etc/apt/sources.list.d/elastic-6.x.list
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | \
sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get install kibana

sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana

# see /etc/kibana/kibana.yml