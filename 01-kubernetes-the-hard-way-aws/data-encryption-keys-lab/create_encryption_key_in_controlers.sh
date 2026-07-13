 
cd ..
bash create_env_variable.sh
KEY_FILE_NAME="encryption-config.yaml"
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
KEY_NAME="k8s_encryption_key"
echo "ENCRIPTION_KEY created"
echo "Writing encription key to key file ${KEY_FILE_NAME}"
cat > "${KEY_FILE_NAME}" <<EOF
apiVersion: v1
resources:
    - resources:
        - secrets:
      providers:
        - aescbc:
            keys:
                -name: "${KEY_NAME}"
                secret: "${ENCRYPTION_KEY}"
EOF
echo "Encryption key ${KEY_NAME} written to key file ${KEY_FILE_NAME}"
echo "Copying key file ${KEY_FILE_NAME} to eks controllers"
for instance in $CONTROLLER_LIST; do
    external_ip=$(aws ec2 describe-instances --region "${AWS_REGION}" --filters \
        "Name=tag:Name,Values=kubernetes-the-hard-way-aws-k8s-${instance}" \
        "Name=instance-state-name,Values=running"
        --output text --query 'Reservations[].Instances[].PublicIpAddress'
    )
     echo "Setting encryption key of ${instance}(IP: ${external_ip}) to ${KEY_NAME}"
     scp -i kubernetes_id.rsa -o StrictHostKeyChecking=no encryption-config.yaml ubuntu@{external_ip}:~/
done