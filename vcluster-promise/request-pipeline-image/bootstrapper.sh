#!/usr/bin/env bash

set -eux -o pipefail

function run() {
until ${@:2}
do
  echo "$1"
  sleep 5
done
}


run "Waiting for vcluster to exist" kubectl -n $NAME wait pod/$NAME-0 --for condition=ContainersReady --timeout=120s


echo "installing gitops-tk"
vcluster connect -n $NAME $NAME -- kubectl apply -f https://raw.githubusercontent.com/syntasso/kratix/main/hack/worker/gitops-tk-install.yaml

curl https://raw.githubusercontent.com/syntasso/kratix/main/hack/worker/gitops-tk-resources.yaml | \
  sed "s/worker-cluster-1/$NAME/g" | \
  sed "s/name: kratix/name: $NAME/g" > resources.yaml

echo "installing gitops-tk-resources"
vcluster connect -n $NAME $NAME -- kubectl apply -f resources.yaml

echo "done"
