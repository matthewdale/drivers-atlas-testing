#!/bin/bash
set -o xtrace

# This script deletes the "example-mongodb-tls-50-v3" MongoDB replicaset in the "drivers" namespace
# in the Kanopy Staging cluster.

# Make sure we're connected to the Kanopy Staging cluster, namespace "drivers".
$(KUBECTL) --namespace drivers config set-context "api.staging.corp.mongodb.com"

# Allow overriding the kubectl binary path. Default to the binaries in the $PATH.
KUBECTL=${KUBECTL:-kubectl}

# Delete the "example-mongodb-tls-50-v3" MongoDB replicaset.
$(KUBECTL) --namespace drivers delete MongoDBCommunity example-mongodb-tls-50-v3

# TODO: Do we need to do this?
# Delete all volume claims associated with the "example-mongodb-tls-50-v3" MongoDB replicaset.
# $(KUBECTL) --namespace drivers delete PersistentVolumeClaim data-volume-example-mongodb-tls-50-v3-0
# $(KUBECTL) --namespace drivers delete PersistentVolumeClaim data-volume-example-mongodb-tls-50-v3-1
# $(KUBECTL) --namespace drivers delete PersistentVolumeClaim data-volume-example-mongodb-tls-50-v3-2
# $(KUBECTL) --namespace drivers delete PersistentVolumeClaim logs-volume-example-mongodb-tls-50-v3-0
# $(KUBECTL) --namespace drivers delete PersistentVolumeClaim logs-volume-example-mongodb-tls-50-v3-1
# $(KUBECTL) --namespace drivers delete PersistentVolumeClaim logs-volume-example-mongodb-tls-50-v3-2

# Delete the TLS certificate issued for the "example-mongodb-tls-50-v3" MongoDB replicaset.
$(KUBECTL) --namespace drivers delete Certificate astrolabe-mongodb-tls
