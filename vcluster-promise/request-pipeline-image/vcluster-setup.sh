#!/bin/bash

# Reference for running in background: https://www.maketecheasier.com/run-bash-commands-background-linux/
nohup vcluster connect my-vcluster-demo -n vcluster-namespace &>/dev/null &
# vcluster -h

vcluster list
kubectl config get-contexts

# Apply the resources to the vcluster
kubectl apply -f namespaces.yaml
kubectl apply -f jaeger.yaml
