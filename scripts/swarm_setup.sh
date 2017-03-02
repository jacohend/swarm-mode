#!/bin/bash

#run from root of aws dir

set +e
getopt --test > /dev/null
if [[ $? != 4  ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi
SHORT=mc
LONG=nodes:,aws_id:,aws_service:,aws_region:,aws_key:,aws_secret:,aws_default_region:,aws_ami:,host_ip:,join_ip:,ssh_key:,aws_vpc:,interface:,network:,ssl_cert:,ssl_lb:,ssl_host:,nodes:,master,client
AWS_ID=
AWS_SERVICE=
AWS_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=

AWS_SECURITY_GROUP=
SECURITY_GROUP_ID=
AWS_INSTANCE_TYPE=
AWS_INSTANCE_PROFILE=

AWS_AMI=
AWS_VPC_ID=
AWS_DOMAIN=
AWS_SUBNET_ID=
DOMAIN=
INTERFACE=
HOST_IP=
PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
NODES=3

if [[ $? != 0  ]]; then
    exit 2
fi
echo "$PARSED"
eval set -- "$PARSED"
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        --aws_id)
            AWS_ID="$2"
            shift 2
            ;;
        --aws_service)
            AWS_SERVICE="$2"
            shift 2
            ;;
        --aws_region)
            AWS_REGION="$2"
            shift 2
            ;;
        --aws_key)
            AWS_ACCESS_KEY_ID="$2"
            shift 2
            ;;
        --aws_secret)
            AWS_SECRET_ACCESS_KEY="$2"
            shift 2
            ;;
        --aws_default_region)
            AWS_DEFAULT_REGION="$2"
            shift 2
            ;;
        --aws_ami)
            AWS_AMI="$2"
            shift 2
            ;;
        --aws_vpc)
            AWS_VPC_ID="$2"
            shift 2
            ;;
        --host_ip)
            HOST_IP="$2"
            shift 2
            ;;
        --join_ip)
            JOIN_IP="$2"
            shift 2
            ;;
        --interface)
            INTERFACE="$2"
            shift 2
            ;;
        --network)
            NETWORK="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --ssl_host)
            SSL_HOST="$2"
            shift 2
            ;;
        --ssl_lb)
            SSL_LB="$2"
            shift 2
            ;;
        --ssl_cert)
            SSL_CERT="$2"
            shift 2
            ;;
        --nodes)
            NODES="$2"
            shift 2
            ;;
        -m|--master)
            NODE="master"
            shift
            ;;
        -c|--client)
            NODE="client"
            shift
            ;;
        --ssh-key)
            SSH_KEY="$2"
            shift 2
            ;;
	    --) shift; break ;;
        *) break;;
    esac
done

curl -L https://github.com/docker/machine/releases/download/v0.9.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 2377 --source-group $SECURITY_GROUP_ID
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 7946 --source-group $SECURITY_GROUP_ID
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol udp --port 7946 --source-group $SECURITY_GROUP_ID
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 4789 --source-group $SECURITY_GROUP_ID
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol udp --port 4789 --source-group $SECURITY_GROUP_ID

#create all machines
for i in $(seq 1 $NODES)
do  
    #set env variables
    NODE="NODE-${AWS_DEFAULT_REGION}-${i}"
    docker-machine create --driver amazonec2 --engine-opt experimental=true --engine-opt metrics-addr=0.0.0.0:4999 --amazonec2-security-group $AWS_SECURITY_GROUP --amazonec2-use-private-address=true --amazonec2-instance-type $AWS_INSTANCE_TYPE $NODE
    docker-machine ssh $NODE sudo usermod -a -G docker ubuntu || true
    docker-machine ssh $NODE sudo gpasswd -a ubuntu docker 
    docker-machine restart $NODE
    sleep 60
    HOST_IP=`docker-machine ip $NODE`
    echo $HOST_IP
    echo $NODE 
    echo " joining "
	if [[ $i == 1  ]]; then
		JOIN_IP=$HOST_IP
        eval $(docker-machine env $NODE)
        docker-machine ssh $NODE docker swarm init --advertise-addr $JOIN_IP
        MANAGER_TOKEN=$(docker-machine ssh $NODE docker swarm join-token --quiet manager)
        CLIENT_TOKEN=$(docker-machine ssh $NODE docker swarm join-token --quiet worker)
        echo $MANAGER_TOKEN
        echo $CLIENT_TOKEN
	fi
    eval $(docker-machine env $NODE)
    echo $JOIN_IP

     #construct aws service url in case you need to access aws services
    AWS_BASE="$AWS_ID.$AWS_SERVICE.$AWS_REGION.$AWS_DOMAIN"

    #install emacs
    docker-machine ssh $NODE sudo apt-get -y update
    sleep 10 
    docker-machine ssh $NODE sudo apt-get -y install emacs24-nox vim clamav awscli

    if [[ $i == 1  ]]; then
        set -e
        echo "host: $HOST_IP"
        echo "join: $JOIN_IP"
        #edit in host setup commands here
    fi

    if [[ $i > 1 ]]; then
        set -e
        echo "host: $HOST_IP"
        echo "join: $JOIN_IP"
        #edit in host setup commands here

        #SWAAAARM
        docker-machine ssh $NODE docker swarm join --token $CLIENT_TOKEN $JOIN_IP:2377 --advertise-addr $HOST_IP:2377 --listen-addr $HOST_IP:2377 || true
    
   fi

done





