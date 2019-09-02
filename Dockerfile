FROM ubuntu:19.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y git ant vim maven inetutils-ping telnet openjdk-11-jdk iptables 
RUN mkdir -p /tmp/zookeeper

ADD zookeeper /tmp/zookeeper

# the following ports are exposed but not necessarily used afterwards 
# expose debug mode port
EXPOSE 5005

# expose client ports (for up to 5 servers)
EXPOSE 2791 2792 2793 2794 2795

# expose servers ports (for up to 5 servers)
EXPOSE 2222 2223 3333 3334 4444 4445 5555 5556 6666 6667
