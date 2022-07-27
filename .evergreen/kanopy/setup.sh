#!/bin/bash
set -o xtrace

# This script runs all of the initial setup required to run a MongoDB replicaset on Kanopy using the
# MongoDB Community Kubernetes Operator (https://github.com/mongodb/mongodb-kubernetes-operator). It
# is only necessary to run this script once to set up a new Kanopy namespace.

# Allow overriding the kubectl, helm, and mkcert binary paths. Default to the binaries in the $PATH.
KUBECTL=${KUBECTL:-kubectl}
HELM=${HELM:-helm}
MKCERT=${MKCERT:-mkcert}

# Install the MongoDB Community Kubernetes Operator.
$(HELM) repo add mongodb https://mongodb.github.io/helm-charts
$(HELM) repo update
$(HELM) --namespace drivers install community-operator mongodb/community-operator \
    --set community-operator-crds.enabled=false

# Create the root CA certificate.
CAROOT=./ $(MKCERT) -install

# Store the root CA certificate for the MongoDB replicaset.
$(KUBECTL) --namespace drivers create configmap astrolabe-mongodb-ca-configmap \
    --from-file=ca.crt=./rootCA.pem

# Store the root CA certificate and key for the CertManager issuer.
$(KUBECTL) --namespace drivers create secret tls astrolabe-mongodb-ca-keypair \
    --cert=./rootCA.pem \
    --key=./rootCA-key.pem

# # Create the CertManager certificate issuer.
$(KUBECTL) --namespace drivers apply -f cert-manager-issuer.yml

if [ -z "$PASSWORD" ]; then
    echo 'Expected database password to be provided in env var $PASSWORD'
    exit 1
fi

# Create the password for database user "astrolabe". Expect the password to be provided in
# environment variable $PASSWORD.
$(KUBECTL) --namespace drivers create secret generic astrolabe-mongodb-password \
    --from-literal=password="$PASSWORD"
