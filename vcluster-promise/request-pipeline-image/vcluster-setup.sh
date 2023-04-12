#!/bin/bash

echo "** VCluster connect"
nohup vcluster connect my-vcluster-demo -n vcluster-namespace --kube-config /root/.kube/config --server my-vcluster-demo &>/dev/null & 

echo "** See kubeconfig"
cat /root/.kube/config

echo "** View VClusters"
vcluster list

echo "** Get pods"
kubectl get pods

# echo "** Starting..."
# echo "** Connect to vcluster!"
# Reference for running in background: https://www.maketecheasier.com/run-bash-commands-background-linux/
# nohup vcluster connect my-vcluster-demo -n vcluster-namespace &>/dev/null &
# vcluster connect my-vcluster-demo -n vcluster-namespace

# echo "** HELLO vcluster?"
# vcluster -h
# vcluster list

# echo "** HELLO kubectl"
# kubectl get pods
# kubectl config get-contexts

# # Apply the resources to the vcluster
# echo "** kubectl apply"
# kubectl apply -f namespaces.yaml
# kubectl apply -f jaeger.yaml
