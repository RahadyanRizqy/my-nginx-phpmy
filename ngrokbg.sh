#!/bin/bash
# ngrok must be placed and run in root server
read -p "Ngrok token: " TOKEN
ngrok config add-authtoken $TOKEN
ngrok tcp 22 --log=stdout > /root/ngrok.log &
command=$(ps aux | grep ngrok | awk '{print $2}' | sed -n '2p');
sleep 5;
host=$(grep "started tunnel" ngrok.log | awk -F'url=' '{print $2}' | cut -d':' -f2 | sed 's/\/\///');
port=$(grep "started tunnel" ngrok.log | awk -F'url=' '{print $2}' | cut -d':' -f3);
echo "Ngrok PID: " $command;
echo "Host: " $host;
echo "Port: " $port;
