#!/usr/bin/env bash

manager_pod=$(kubectl --context kind-platform --namespace kratix-platform-system \
    get pods --selector control-plane=controller-manager \
    --output custom-columns=:metadata.name --no-headers)

kubectl --context kind-platform logs --namespace kratix-platform-system \
    pod/${manager_pod} --container manager "$@"