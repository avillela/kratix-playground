#!/usr/bin/env bash

manager_pod=$(kubectl --namespace kratix-platform-system \
    get pods --selector control-plane=controller-manager \
    --output custom-columns=:metadata.name --no-headers)

kubectl logs --namespace kratix-platform-system \
    pod/${manager_pod} --container manager "$@" -f