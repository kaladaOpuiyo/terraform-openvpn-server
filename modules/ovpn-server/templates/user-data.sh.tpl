#!/bin/bash
#Ref:https://dev.to/aws/amazon-route-53-how-to-automatically-update-ip-addresses-without-using-elastic-ips-h7o
# Extract information about the Instance
MY_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4/)

# Extract tags associated with instance
ZONE=${dns_zone}
NAME=${fqdn}

# Update Route 53 Record Set based on the Name tag to the current Public IP address of the Instance
aws route53 change-resource-record-sets --hosted-zone-id $ZONE --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$NAME'","Type":"A","TTL":300,"ResourceRecords":[{"Value":"'$MY_IP'"}]}}]}'
