Prerequisites: docker-engine 1.13, bash, awscli (if you're spinning up aws docker-machines)

**Example deployment of a docker-compose V3 stack onto a 1.13+ swarm**

1. build example stack: ```./run-swarm.sh build```

1. run stack on swarm (ignore errors about pre-existing stacks): ```./run-swarm.sh run```

1. After a few seconds, test service ```curl localhost:8080```

1. scale example service: ```./run-swarm.sh scale```

1. remove stack from swarm: ```./run-swarm.sh rm```


**To run this or your own example on an AWS Swarm:**

1. Edit your AWS credentials into scripts/swarm_setup.sh and make sure the awscli binary is setup for your aws account. 

1. Execute ```./swarm_setup.sh``` to create a multi-host swarm cluster to your specification

1. Access your manager node using ```docker-machine ssh <NODE_NAME>``` 

1. Copy the repo onto your swarm manager and execute ```./run-swarm.sh run```
