#!/bin/bash
set -o xtrace

# This script creates a 3-node MongoDB replicaset named "example-mongodb-tls-50-v3" in the "drivers"
# namespace in the Kanopy Staging cluster.

# Allow overriding the kubectl binary path. Default to the binaries in the $PATH.
KUBECTL=${KUBECTL:-kubectl}

# Make sure we're connected to the Kanopy Staging cluster, namespace "drivers".
$(KUBECTL) --namespace drivers config set-context "api.staging.corp.mongodb.com"

# Create the Cert Manager TLS certificate for the MongoDB replicaset.
$(KUBECTL) --namespace drivers apply -f cert-manager-certificate.yml

# Create the 3-node MongoDB replicaset "example-mongodb-tls-50-v3".
$(KUBECTL) --namespace drivers apply -f mongodb.yml

# TODO: Where to download these?
# Download the CA and server TLS certificates.
$(KUBECTL) --namespace drivers get configmap astrolabe-mongodb-ca-configmap -o json \
    | jq -r '.data."ca.crt"' > ca.pem
$(KUBECTL) --namespace drivers get secret astrolabe-mongodb-tls -o json \
    | jq -r '.data."tls.crt", .data."tls.key" | @base64d' > key.pem

# Wait up to 120s for the "example-mongodb-tls-50-v3" MongoDB replicaset to be in phase "Running".
$(KUBECTL) --namespace drivers wait MongoDBCommunity/example-mongodb-tls-50-v3 \
    --for=jsonpath='{.status.phase}'=Running \
    --timeout=120s
