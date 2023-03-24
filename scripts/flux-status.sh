#!/usr/bin/env bash

if ! kubectl get namespace flux-system >/dev/null; then
    continue
fi

echo "================================="
kubectl get kustomizations -A
echo ""

# for cluster in "platform" $(kind get clusters | grep -v platform); do
#     if ! kind get clusters | grep $cluster >/dev/null; then
#         continue
#     fi

#     if ! kubectl get namespace flux-system --context kind-${cluster} >/dev/null; then
#         continue
#     fi

#     echo "================================="
#     echo "           $(echo ${cluster} | tr [:lower:] [:upper:])"
#     echo "================================="
#     kubectl get kustomizations -A --context=kind-${cluster}
#     echo ""
# done