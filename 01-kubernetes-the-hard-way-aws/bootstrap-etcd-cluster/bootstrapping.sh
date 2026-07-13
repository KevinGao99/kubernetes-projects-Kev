set -euo pipefail

cd ..
source create_env_variables.sh

: "${AWS_REGION:?AWS_REGION is not set}"

CONTROLLER_LIST="${CONTROLLER_LIST:-controller-0 controller-1 controller-2}"

chmod 400 kubernetes_id.pem

INITIAL_CLUSTER="k8s-controller-0=https://10.0.1.10:2380,k8s-controller-1=https://10.0.1.11:2380,k8s-controller-2=https://10.0.1.12:2380"

for instance in $CONTROLLER_LIST; do
  echo "========================================"
  echo "Configuring etcd on ${instance}"
  echo "========================================"

  external_ip=$(aws ec2 describe-instances --region "${AWS_REGION}" --filters \
    "Name=tag:Name,Values=kubernetes-the-hard-way-aws-k8s-${instance}" \
    "Name=instance-state-name,Values=running" \
    --output text \
    --query 'Reservations[].Instances[].PublicIpAddress')

  if [ -z "${external_ip}" ] || [ "${external_ip}" = "None" ]; then
    echo "ERROR: Could not find public IP for ${instance}"
    exit 1
  fi

  etcd_name="k8s-${instance}"

  echo "${instance} public IP: ${external_ip}"
  echo "${instance} etcd name: ${etcd_name}"

  ssh -i kubernetes_id.pem -o StrictHostKeyChecking=no ubuntu@"${external_ip}" \
    "ETCD_NAME='${etcd_name}' INITIAL_CLUSTER='${INITIAL_CLUSTER}' bash -s" <<'REMOTE_SCRIPT'
set -euo pipefail

echo "Stopping etcd if already running..."
sudo systemctl stop etcd || true
sudo systemctl reset-failed etcd || true

echo "Wiping old etcd data dir..."
sudo rm -rf /var/lib/etcd

echo "Preparing etcd directories..."
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo chmod 700 /var/lib/etcd

echo "Copying certificates..."
sudo cp /home/ubuntu/ca.pem /home/ubuntu/kubernetes-key.pem /home/ubuntu/kubernetes.pem /etc/etcd/

INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "INTERNAL_IP=${INTERNAL_IP}"
echo "ETCD_NAME=${ETCD_NAME}"
echo "INITIAL_CLUSTER=${INITIAL_CLUSTER}"

cat <<EOF | sudo tee /etc/systemd/system/etcd.service >/dev/null
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${INITIAL_CLUSTER} \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Generated etcd.service:"
sudo grep -E -- '--name|initial-advertise-peer|listen-peer|listen-client|advertise-client|initial-cluster' /etc/systemd/system/etcd.service


REMOTE_SCRIPT

done