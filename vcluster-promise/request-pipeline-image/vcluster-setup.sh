#!/bin/bash

# Do this in another pipeline first??
echo "** Apply k8s permissions"
# kubectl apply -f kubectl-in-k8s.yaml

# Reference for running in background: https://www.maketecheasier.com/run-bash-commands-background-linux/
nohup vcluster connect my-vcluster-demo -n vcluster-namespace &>/dev/null &

echo "** HELLO vcluster"
vcluster -h
vcluster list

echo "** HELLO kubectl"
kubectl get pods
kubectl config get-contexts

# Apply the resources to the vcluster
# kubectl apply -f namespaces.yaml
# kubectl apply -f jaeger.yaml
