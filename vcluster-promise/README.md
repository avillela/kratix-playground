# VCluster Promise

In this version of the [VCluster](https://www.vcluster.com/) Promise, the Promise creates a Vcluster. The pipeline is blank, becaise there isn't really anything else to do? Ideally, I'd like for the pipeline to [deploy Jaeger](test/) in the vcluster, but I have no idea how to do that with Kratix. I think that the answer lies [in here](https://www.vcluster.com/docs/operator/external-access).


1. Get VCluster manifest

    Grab the VCluster manifest from the Helm chart

    ```bash
    # Helm install
    helm repo add loft-sh https://charts.loft.sh
    helm repo update

    helm template my-vcluster-demo loft-sh/vcluster-k8s -n vcluster-namespace > vcluster-promise/resources/vcluster.yaml
    ```

2. Pipeline setup

    Create the pipeline. Start by creating and building the Pipeline image. This pipeline will create a Jaeger instance in your vcluster

    ```bash
    # Local build
    docker build -t vcluster-request-pipeline:dev ./vcluster-promise/request-pipeline-image/

    # Local run
    docker run -v $PWD/vcluster-promise/request-pipeline-image/input:/input -v $PWD/vcluster-promise/request-pipeline-image/output:/output vcluster-request-pipeline:dev

    # Push to GHCR
    export GH_TOKEN="<your_gh_pat>"
    export GH_USER="<your_gh_username>"
    export IMAGE="vcluster-request-pipeline:dev"

    docker buildx build --push -t ghcr.io/$GH_USER/$IMAGE --platform=linux/arm64,linux/amd64 ./vcluster-promise/request-pipeline-image/
    ```

3. Install the Promise

    ```bash
    kubectl apply -f vcluster-promise/promise.yaml
    ```