#!/usr/bin/env bash

NAME=test
NAMESPACE=ns

COMMON_NAME=${NAME}.${NAMESPACE}

set -eo pipefail

mkdir -p ./tmp
cd ./tmp

echo ">>> Generate CA key and certificate"
cat <<EOF | cfssl gencert -initca - | cfssljson -bare ca
{
  "CN": "Dev Root CA",
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
EOF

# 8760 hours = 365 days

CFSSL_CONFIG=$(cat <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "server": {
        "usages": [
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF
)

echo ">>> Generate cert.key and cert.crt"

cat <<EOF | cfssl gencert -ca ca.pem -ca-key ca-key.pem -config <(echo "$CFSSL_CONFIG") -profile=server - | cfssljson -bare tls
{
  "CN": "${COMMON_NAME}.svc",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "hosts": [
    "localhost",
    "127.0.0.1",
    "${COMMON_NAME}",
    "${COMMON_NAME}.svc",
    "${COMMON_NAME}.svc.cluster.local"
  ]
}
EOF
