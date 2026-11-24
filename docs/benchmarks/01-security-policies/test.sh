#!/bin/bash

set +a
source ../../../docker/.env
set -a

check_connection() {
    ID="$1"
    IP="$2"
    PORT="$3"
    DESCRIPTION="$4"

    echo "🔍 Testing connection to ${DESCRIPTION} at ${IP}:${PORT}"

    docker exec "${ID}" /bin/bash -c "nc -z -w 3 ${IP} ${PORT}"

    if [ $? -eq 0 ]; then
        echo "🟢 Connection is successful!"
    else
        echo "🔴 Connection failed!"
    fi
}

# Deploy infrastructure

terraform init
terraform apply -auto-approve

# Get endpoints

# EC2 endpoint is equal to ip + custom listen port
LISTENER_INSTANCE_IP="$(terraform output -raw listener_ip)"
LISTENER_INSTANCE_PORT="$(terraform output -raw listener_port)"

# RDS endpoint is equal to endpoint managed by floci
RDS_INSTANCE_IP="$(terraform output -raw db_instance_ip)"
RDS_INSTANCE_PORT="$(terraform output -raw db_instance_port)"

# Get docker container name which equals to floci ec2 prefix + floci instance id
LISTENER_CONTAINER_NAME="$(terraform output -raw listener_instance_id)"
ATTACKER_CONTAINER_NAME="$(terraform output -raw attacker_instance_id)"

echo -e "\nFLOCI_NETWORK_SECURITY_GROUP_ENFORCEMENT_ENABLED is set to ${FLOCI_NETWORK_SECURITY_GROUP_ENFORCEMENT_ENABLED}\n"

# When FLOCI_NETWORK_SECURITY_GROUP_ENFORCEMENT_ENABLED is true
# Floci runs EC2 instances inside a hidden parent container that owns the network
# The EC2 container itself has no unique IP, so to test the connection, we must extract and use the parent container's IP address

if ${FLOCI_NETWORK_SECURITY_GROUP_ENFORCEMENT_ENABLED}; then

    LISTENER_SG_CONTAINER_NAME="$(terraform output -raw listener_sg_id)"

    LISTENER_INSTANCE_IP="$(docker inspect -f '{{ range.NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' ${LISTENER_SG_CONTAINER_NAME})"

fi

check_connection "${ATTACKER_CONTAINER_NAME}" "${LISTENER_INSTANCE_IP}" "${LISTENER_INSTANCE_PORT}" "EC2 listener server"
echo ""
check_connection "${ATTACKER_CONTAINER_NAME}" "${RDS_INSTANCE_IP}" "${RDS_INSTANCE_PORT}" "RDS instance"
