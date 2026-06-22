cd ..
for instance in worker-0 worker-1 worker-2; do
    external_ip=$(aws ec2 describe-instances --region us-east-2 --filters \
    "Name=tag:Name,Values=dev-k8s-training-${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
    echo "External IP retrieved: ${external_ip}"
    scp -i kubernetes_id.pem -o StrictHostKeyChecking=no ca.pem ${instance}-key.pem ubuntu@${external_ip}:~/
done