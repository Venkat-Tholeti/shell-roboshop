#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-02931c1532cf4e8e0"
INSTANCES=("mongodb" "redis" "mysql" "rabitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z01053453ISR026N9BIT1"
DOMAIN_NAME="devopsaws.store"

for instance in ${INSTANCES[0]}
do
 INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-02931c1532cf4e8e0 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        
    fi
    echo "$instance IP address: $IP"
done