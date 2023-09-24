#!/bin/bash

oldhostname=$(hostname)
read -p "Enter the new hostname: " newhostname

echo $newhostname > /etc/hostname
sudo sed -i "s/$oldhostname/$newhostname/" /etc/hosts
