#!/bin/bash
# must add the token first
touch ngrok.log
ngrok tcp 22 --log=stdout > ngrok.log &
command=$(ps aux | grep ngrok | awk '{print $2}' | sed -n '2p');
sleep 5;
host=$(grep "started tunnel" ngrok.log | awk -F'url=' '{print $2}' | cut -d':' -f2 | sed 's/\/\///');
port=$(grep "started tunnel" ngrok.log | awk -F'url=' '{print $2}' | cut -d':' -f3);
echo "Ngrok PID: " $command;
echo "Host: " $host;
echo "Port: " $port;
