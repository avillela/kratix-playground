#!/usr/bin/env bash

if ! kubectl get namespace flux-system >/dev/null; then
    continue
fi

echo "================================="
kubectl get kustomizations -A
echo ""
