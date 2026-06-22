cd ..
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names":[{
    "C": "US",
    "ST": "Portland",
    "L": "Kubernetes",
    "O": "CA",
    "OU": "Oregon"
  }]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca