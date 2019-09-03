# Debugging ZooKeeper
This repository contains a script that can be used to **easily** debug ZooKeeper code. The script can be used to run a ZK cluster locally, while remotely debugging one of the servers using IntelliJ IDEA.

#### Requirements
- [Docker](https://www.docker.com)
- [tmux](https://github.com/tmux/tmux)


## How to run?
After having docker running, you simply execute:

```./debug_zk.sh```

The first time the script is executed, it clones the latest version of [ZooKeeper](https://github.com/apache/zookeeper).
The script then build ZooKeeper and creates a tmux sessions that includes a window for each of the ZooKeeper servers (running in foreground) as seen below.
![](zk_debug_1.png)

The first tmux window contains a client connected to the cluster and can be used to issue commands against the cluster.

Note that the ZooKeeper server in the second tmux window is not running: 
![](zk_debug_2.png) 
This is because it waits to be connected to IntelliJ for remote debugging. For this, first import (see below) the ZooKeeper codebase in IntelliJ.
![](zk_debug_import.png)

When you start remote debugging from IntelliJ, the first server starts.
![](zk_debug_run.png)

## How to connect to ZooKeeper servers?
You can easily connect to any ZooKeeper server from local machine by doing:

``` ./zookeeper/bin/zkCli.sh -server 127.0.0.1:2791``` (for connecting to the first server)

or even 

```telnet localhost 2792```

and then issuing some [4wl command](https://zookeeper.apache.org/doc/r3.4.8/zookeeperAdmin.html#sc_zkCommands).

## How to partition the network?
If you would like to see how ZooKeeper performs under a network partition, you can simply use `iptables` and perform similar commands as the ones shown in [`create_np.sh`](create_np.sh) or [`heal_np.sh`](heal_np.sh) to heal a network partition.
