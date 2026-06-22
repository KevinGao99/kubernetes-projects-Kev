cd ..
for instance in controller-0 controller-1 controller-2; do
  external_ip=$(aws ec2 describe-instances --region us-east-2 --filters \
    "Name=tag:Name,Values=kubernetes-the-hard-way-aws-k8s-${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text --query 'Reservations[].Instances[].PublicIpAddress')
    echo "Setting ${instance}: IP ${external_ip}"
  scp -i kubernetes_id.pem -o StrictHostKeyChecking=no \
    ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ubuntu@${external_ip}:~/
done