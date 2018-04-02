#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then 
    echo "Please run this script as root"
    exit 1
fi

# Check if apt-transport-https is installed
if ! [[ -x "$(command -v apt-transport-https)" ]]; then
    sudo apt-get install apt-transport-https
fi

# Check if Java is installed
if ! [[ -x "$(command -v java -version)" ]]; then
  echo 'Error: java is not installed, installing ...'

  sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | \
  sudo tee -a /etc/apt/sources.list
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
  sudo apt-get update 

  # Accept license
  sudo echo oracle-java9-installer shared/accepted-oracle-license-v1-1 select true | \
  sudo /usr/bin/debconf-set-selections
  
  # Elasticsearch v.6.2.x has Java 9 Support, Java 7 is no longer available
  sudo apt-get install -y oracle-java9-installer
  echo 'Java installation done'
fi

java -version

mkdir -p elasticsearch && cd $_

ARTIFACT_NAME="elasticsearch-6.2.3.deb"

wget "https://artifacts.elastic.co/downloads/elasticsearch/${ARTIFACT_NAME}"
wget "https://artifacts.elastic.co/downloads/elasticsearch/${ARTIFACT_NAME}.sha512"

# Validate checksum
SHA512_CALCULATED=`sha512sum ${ARTIFACT_NAME}`
SHA512_DOWNLOADED=`cat ${ARTIFACT_NAME}.sha512`

printf "Validating checksum ... "

if [[ "$SHA512_CALCULATED" != "$SHA512_DOWNLOADED" ]]; then
    printf "Invalid checksum.\n"
    exit 1
else
    printf "OK.\n"
fi

sudo dpkg -i "./${ARTIFACT_NAME}"

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# TODO: reboot necessary? 