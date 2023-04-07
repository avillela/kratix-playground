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

2. Install the Promise

    ```bash
    kubectl apply -f vcluster-promise/promise.yaml
    ```