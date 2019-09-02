#!/bin/bash

# creating a network partition example script

# server1 only connects to server2 and server3 
docker exec -it server1 iptables -A INPUT -s server4 -j DROP
docker exec -it server1 iptables -A INPUT -s server5 -j DROP
docker exec -it server4 iptables -A INPUT -s server1 -j DROP
docker exec -it server5 iptables -A INPUT -s server1 -j DROP

# server2 only connects to server1 and server3 
docker exec -it server2 iptables -A INPUT -s server4 -j DROP
docker exec -it server2 iptables -A INPUT -s server5 -j DROP
docker exec -it server4 iptables -A INPUT -s server2 -j DROP
docker exec -it server5 iptables -A INPUT -s server2 -j DROP

# server3 only connects to server1 and server2 
docker exec -it server3 iptables -A INPUT -s server4 -j DROP
docker exec -it server3 iptables -A INPUT -s server5 -j DROP
docker exec -it server4 iptables -A INPUT -s server3 -j DROP
docker exec -it server5 iptables -A INPUT -s server3 -j DROP
