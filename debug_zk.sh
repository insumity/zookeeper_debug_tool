#!/bin/bash

# get zookeeper only if not here
if [ ! -d "zookeeper" ]
then
    git clone https://github.com/apache/zookeeper.git
fi

(cd zookeeper; ant compile; ant eclipse -Dmaven.test.skip=true)


docker rmi -f zookeeper_server
docker build -t zookeeper_server -f Dockerfile . 

DEBUG=false
if [[ $1 = true ]];
then
    DEBUG=true
fi

DEBUG_PORT=5005
DEBUG_SERVER=1
NUM_SERVERS=5

# configuration file creation, based on template.cfg
# only the data directory and the client port change, everything else is in template.cfg
for i in $(seq 1 $NUM_SERVERS);
do
    clientPort=$((2790+$i))
    (cd configuration_files; sed "s/\$dataDir/server$i/g;s/\$clientPort/$clientPort/g" template.cfg > server$i.cfg)
done
echo 'Created configuration files'


# kill and remove containers if already there
for i in $(seq 1 $NUM_SERVERS);
do
    docker kill server$i
    docker rm server$i
done 

docker network rm zookeeper_network
docker network create --driver bridge zookeeper_network

# create and run containers
for i in $(seq 1 $NUM_SERVERS);
do
    clientPort=$((2790+$i))
    serverPortA=$((1111*$(($i + 1))))
    serverPortB=$(($serverPortA+1))

    if $DEBUG;
    then
        if [[ $i -eq $DEBUG_SERVER ]];
        then
            docker run --privileged -d --net=zookeeper_network --name server$i -p $clientPort:$clientPort \
                -p $serverPortA:$serverPortA -p $serverPortB:$serverPortB -p $DEBUG_PORT:$DEBUG_PORT -it zookeeper_server /bin/bash
        else
            docker run --privileged -d --net=zookeeper_network --name server$i -p $clientPort:$clientPort \
                -p $serverPortA:$serverPortA -p $serverPortB:$serverPortB -it zookeeper_server /bin/bash
        fi
    else
        docker run --privileged -d --net=zookeeper_network --name server$i -p $clientPort:$clientPort \
            -p $serverPortA:$serverPortA -p $serverPortB:$serverPortB -it zookeeper_server /bin/bash
    fi

    docker cp configuration_files/server$i.cfg server$i:/tmp/zookeeper/conf
    docker cp zkDebugServer.sh server$i:/tmp/zookeeper/bin
    docker exec server$i mkdir /tmp/zookeeper/server$i /tmp/zookeeper/server$i/data
    docker exec server$i bash -c "echo $i > /tmp/zookeeper/server$i/data/myid"

done

tmux kill-session -t "zookeeper_session"
tmux new -s "zookeeper_session" -d -n "client"
for i in $(seq 1 $NUM_SERVERS);
do
    tmux new-window -n "server$i" -t "zookeeper_session"
    tmux send-keys -t "zookeeper_session":"server$i" "docker attach server$i" C-m

    # set SERVER_JVMFLAGS in order to be able to perform reconfigs (from here: https://community.hortonworks.com/articles/29900/zookeeper-using-superdigest-to-gain-full-access-to.html)
    tmux send-keys -t "zookeeper_session":"server$i" "export SERVER_JVMFLAGS=-Dzookeeper.DigestAuthenticationProvider.superDigest=super:UdxDQl4f9v5oITwcAsO9bmWgHSI=" C-m

    if $DEBUG;
    then
        if [ $i -eq $DEBUG_SERVER ]
        then    
            tmux send-keys -t "zookeeper_session":"server$i" "/tmp/zookeeper/bin/zkDebugServer.sh start-foreground /tmp/zookeeper/conf/server$i.cfg" C-m
        else
            tmux send-keys -t "zookeeper_session":"server$i" "/tmp/zookeeper/bin/zkServer.sh start-foreground /tmp/zookeeper/conf/server$i.cfg" C-m
        fi
    else
        tmux send-keys -t "zookeeper_session":"server$i" "/tmp/zookeeper/bin/zkServer.sh start-foreground /tmp/zookeeper/conf/server$i.cfg" C-m
    fi
done

# start the client that is connected in server2
tmux send-keys -t "zookeeper_session":"client" "./zookeeper/bin/zkCli.sh -server 127.0.0.1:2792" C-m
tmux send-keys -t "zookeeper_session":"client" "addauth digest super:super123" C-m

tmux attach -t "zookeeper_session"

