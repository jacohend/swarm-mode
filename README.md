**Example deployment of a docker-compose V3 stack onto a 1.13+ swarm**

* build example stack: ./run-swarm.sh build

* run stack on swarm: ./run-swarm run

* remove stack from swarm: ./run-swarm rm

* scale example service: ./run-swarm scale

**To run this or your own example on an AWS Swarm:**

1. Edit your AWS credentials into scripts/swarm_setup.sh and make sure the awscli binary is setup for your aws account. 
1. Execute ```./swarm_setup.sh``` to create a multi-host swarm cluster to your specification
1. Access your manager node using ```docker-machine ssh <NODE_NAME>``` 
1. Copy the repo onto your swarm manager and execute ```./run-swarm run```
