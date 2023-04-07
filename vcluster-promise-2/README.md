# VCluster Promise

In this version of the [VCluster](https://www.vcluster.com/)  Promise, the Promise creates a dummy namespace, and then the pipeline then installs vcluster in the worker cluster. This feels hacky, and I don't think that this is the right approach.

1. Get VCluster manifest

Grab the VCluster manifest from the Helm chart

```bash
# Helm install
helm repo add loft-sh https://charts.loft.sh
helm repo update

helm template my-vcluster-demo loft-sh/vcluster-k8s -n vcluster-namespace > vcluster-promise-2/request-pipeline-image/vcluster.yaml
```

2. Pipeline setup

Create the pipeline. Start by creating and building the Pipeline image. This pipeline will create a Jaeger instance in your vcluster

```bash
# Local build
docker build -t vcluster-request-pipeline:dev ./vcluster-promise-2/request-pipeline-image/

# Local run
docker run -v $PWD/vcluster-promise-2/request-pipeline-image/input:/input -v $PWD/vcluster-promise-2/request-pipeline-image/output:/output vcluster-request-pipeline:dev

# Push to GHCR
export GH_TOKEN="<your_gh_pat>"
export GH_USER="<your_gh_username>"
export IMAGE="vcluster-request-pipeline:dev"

docker buildx build --push -t ghcr.io/$GH_USER/$IMAGE --platform=linux/arm64,linux/amd64 ./vcluster-promise-2/request-pipeline-image/
```

3. Install the Promise

    ```bash
    kubectl apply -f vcluster-promise-2/promise.yaml
    ```

4. Request the resource

    ```bash
    kubectl apply -f vcluster-promise-2/vcluster-resource-request.yaml
    ```

5. Test

    [Install the vcluster CLI](https://www.vcluster.com/docs/getting-started/setup), then open up a terminal window and run:

    ```bash
    vcluster connect my-vcluster-demo -n host-namespace
    ```

    Open up a new terminal window:

    ```bash
    kubectl apply -f vcluster-promise-2/test/namespaces.yaml
    kubectl apply -f vcluster-promise-2/test/jaeger.yaml
    ```
