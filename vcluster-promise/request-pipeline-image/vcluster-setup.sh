#!/bin/bash

# Do this in another pipeline first??
# Create role/rolebinding for vcluster-default-promise-pipeline?
# echo "** Apply k8s permissions"
# kubectl apply -f kubectl-in-k8s.yaml

echo "** Connect to vcluster"
# Reference for running in background: https://www.maketecheasier.com/run-bash-commands-background-linux/
nohup vcluster connect my-vcluster-demo -n vcluster-namespace &>/dev/null &
# vcluster connect my-vcluster-demo -n vcluster-namespace

echo "** HELLO vcluster?"
# vcluster -h
vcluster list

echo "** HELLO kubectl"
kubectl get pods
kubectl config get-contexts

# Apply the resources to the vcluster
echo "** kubectl apply"
kubectl apply -f namespaces.yaml
kubectl apply -f jaeger.yaml
