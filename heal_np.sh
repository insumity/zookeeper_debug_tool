#!/bin/bash

docker exec -it server1 iptables -F
docker exec -it server2 iptables -F
docker exec -it server3 iptables -F
docker exec -it server4 iptables -F
docker exec -it server5 iptables -F
