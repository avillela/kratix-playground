#!/usr/bin/env sh

set -x

echo "*** Before:"
ls -al /output

# Read current values from the provided resource request
# This is only using the name of the Resource Request rather than any data from the spec
export name="$(yq eval '.metadata.name' /input/object.yaml)"

echo "*** Name: $name"

# Generate VCluster resources with custom name
helm template $name vcluster \
  --repo https://charts.loft.sh \
  --namespace $name \
  --repository-config='' > /output/vcluster.yaml

# Generate the namespace we want to install the VCluster into
cat > /output/namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $name
EOF

# Generate the Kratix Cluster object that will register the VCluster as a worker
# Note the label with the VCluster name in it, this is a unique identifier for scheduling work to this specific cluster
cat > /output/cluster.yaml <<EOF
apiVersion: platform.kratix.io/v1alpha1
kind: Cluster
metadata:
  name: $name
  namespace: default
  labels:
    environment: dev
    vclusterName: $name
spec:
  id: $name-id
  bucketPath: $name
EOF

# Kratix does not "push" anything to worker clusters, they need to pull data in themsevles, often through GitOps
# This job will install the necessary Flux components to read and reconcile to the buckets Kratix is writing to
# NOTE: This is using the same docker image as the pipeline since it relies on some of the same software. This is lazy. Sorry 😅
cat > /output/job.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: bootstrapper
  namespace: $name
spec:
  template:
    spec:
      serviceAccount: bootstrapper
      containers:
      - name: bootstrapper
        image: ghcr.io/avillela/vcluster-request-pipeline:v0.2.0
        command: ["sh",  "-c", "./bootstrapper"]
        env:
        - name: NAME
          value: $name
      restartPolicy: Never
  backoffLimit: 4
EOF

# These are the permissions needed for the job to succeed
cat > /output/sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bootstrapper
  namespace: $name
EOF
cat > /output/crb.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $name-bootstrapper-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: ServiceAccount
  name: bootstrapper
  namespace: $name
EOF

# Create a resource request to a Promise that will install Jaeger

cat > /output/jaeger-resource-request.yaml <<EOF
apiVersion: example.promise/v1
kind: jaeger
metadata:
  name: $name
  namespace: default
spec:
  clusterSelectors:
    vclusterName: $name
EOF


echo "*** After:"
ls -al /output