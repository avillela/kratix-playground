# VCluster Promise

> **NOTE:** This is a work in progress!!

This Promise creates a [VCluster](https://www.vcluster.com/). The pipeline is blank, becaise there isn't really anything else to do? Ideally, I'd like for the pipeline to [deploy Jaeger](test/) in the VCluster, but I have no idea how to do that with Kratix. I think that the answer lies [in here](https://www.vcluster.com/docs/operator/external-access).


1. Get VCluster manifest

    Grab the VCluster manifest from the Helm chart

    ```bash
    # Helm install
    helm repo add loft-sh https://charts.loft.sh
    helm repo update

    helm template my-vcluster-demo loft-sh/vcluster-k8s -n vcluster-namespace > vcluster-promise/resources/vcluster.yaml
    ```

2. Install the Promise

    ```bash
    kubectl apply -f vcluster-promise/promise.yaml
    ```

3. Test

    [Install the vcluster CLI](https://www.vcluster.com/docs/getting-started/setup), then open up a terminal window and run:

    ```bash
    vcluster connect my-vcluster-demo -n vcluster-namespace
    ```

    Open up a new terminal window:

    ```bash
    kubectl apply -f vcluster-promise/test/namespaces.yaml
    kubectl apply -f vcluster-promise/test/jaeger.yaml
    ```


## VCluster Tests

```bash
kubectl --context $PLATFORM_GKE create ns vcluster-namespace
kubectl --context $PLATFORM_GKE apply -f vcluster-promise/resources/vcluster.yaml 

vcluster --context $PLATFORM_GKE connect my-vcluster-demo -n vcluster-namespace
kubectl --context $VCLUSTER_GKE apply -f vcluster-promise/test/namespaces.yaml
kubectl --context $VCLUSTER_GKE apply -f vcluster-promise/test/jaeger.yaml
```

## VCluster Setup

>**NOTE:** Run [`./scripts/quick-start.sh`](https://github.com/syntasso/kratix/blob/main/scripts/quick-start.sh) from local copy of [Kratix repo](https://github.com/syntasso/kratix) (see below)

```bash
./<path_to_kratix_repo>/scripts/quick-start.sh

export PLATFORM="kind-platform"
export WORKER="kind-worker"
export VCLUSTER="vcluster_my-vcluster-demo_vcluster-namespace_kind-worker"

# Install promise (you should see the vcluster-namespace in the worker cluster)
kubectl apply --context $PLATFORM -f vcluster-promise/promise.yaml

# Wait for vcluster to come up before applying this
kubectl apply --context $PLATFORM -f vcluster-promise/vcluster-resource-request.yaml

# Logs
kubectl --context $PLATFORM logs -n kratix-platform-system deployment/kratix-platform-controller-manager --container manager -f

vcluster --context $WORKER connect my-vcluster-demo -n vcluster-namespace
kubectl --context $VCLUSTER apply -f vcluster-promise/test/namespaces.yaml
kubectl --context $VCLUSTER apply -f vcluster-promise/test/jaeger.yaml
```

## kubectl in k8s

Reference [here](https://stackoverflow.com/a/60928656)

```bash
kubectl --context $WORKER create ns my-namespace

kubectl --context $WORKER run curl --image=radial/busyboxplus:curl -i --tty -n my-namespace

# Ref: https://kodekloud.com/community/t/unknown-tag-generator/25444/2
kubectl --context $WORKER run --image=ubuntu -n my-namespace myfirstpod -- labels=example=myfirstpod

kubectl --context $WORKER apply -f vcluster-promise/test/kubectl-in-k8s.yaml

# Test
kubectl --context $WORKER logs job/testing-stuff -n my-namespace
```

# Test vcluster pipeline

```bash
# Build
docker build -t vcluster-pipeline:dev ./vcluster-promise/request-pipeline-image/

# Test
docker run -it --rm vcluster-pipeline:dev /bin/bash

# Push
docker buildx build --push -t ghcr.io/$GH_USER/vcluster-pipeline:dev --platform=linux/arm64,linux/amd64 ./vcluster-promise/request-pipeline-image/
  
```