# VCluster Promise

In this version of the [VCluster](https://www.vcluster.com/) Promise, the Promise creates a Vcluster. The pipeline is blank, becaise there isn't really anything else to do? Ideally, I'd like for the pipeline to [deploy Jaeger](test/) in the vcluster, but I have no idea how to do that with Kratix. I think that the answer lies [in here](https://www.vcluster.com/docs/operator/external-access).


1. Build vcluster Docker image

    ```bash
    export TAG="v0.2.0"
    export GH_USER="<my_gh_user>"

    # Cleanup
    docker rmi -f (docker images -f=reference='vcluster-request-pipeline:*' --format "{{.ID}}")

    # Build
    docker build -t vcluster-request-pipeline:$TAG ./vcluster-promise/request-pipeline-image/

    # Test locally
    cp vcluster-promise/demo-resource-request.yaml vcluster-promise/request-pipeline-image/input/object.yaml

    docker run -v $PWD/vcluster-promise/request-pipeline-image/input:/input -v $PWD/vcluster-promise/request-pipeline-image/output:/output vcluster-request-pipeline:$TAG

    # Publish to Docker registry
    docker buildx build --push -t ghcr.io/$GH_USER/vcluster-request-pipeline:$TAG --platform=linux/arm64,linux/amd64 ./vcluster-promise/request-pipeline-image/
    ```

2. Build Jaeger Docker image

    ```bash
    export TAG="v0.1.0"
    export GH_USER="<my_gh_user>"

    # Cleanup
    docker rmi -f (docker images -f=reference='jaeger-request-pipeline:*' --format "{{.ID}}")

    # Build
    docker build -t jaeger-request-pipeline:$TAG ./jaeger-promise/request-pipeline-image/

    docker run -v $PWD/jaeger-promise/request-pipeline-image/input:/input -v $PWD/jaeger-promise/request-pipeline-image/output:/output jaeger-request-pipeline:$TAG

    # Publish to Docker registry
    docker buildx build --push -t ghcr.io/$GH_USER/jaeger-request-pipeline:$TAG --platform=linux/arm64,linux/amd64 ./jaeger-promise/request-pipeline-image/
    ```

3. Install the Promise

    ```bash
    kubectl apply --context $PLATFORM -f vcluster-promise/promise.yaml

    kubectl apply --context $PLATFORM -f jaeger-promise/promise.yaml
    ```

4. Make the resource request

    ```bash
    kubectl apply --context $PLATFORM -f vcluster-promise/demo-resource-request.yaml

    # Verify
    kubectl logs --selector=kratix-promise-id=vcluster-default --container xaas-request-pipeline-stage-0 --follow
    kubectl logs --selector=kratix-promise-id=vcluster-default --container status-writer
    kubectl logs --selector=kratix-promise-id=vcluster-default --container work-writer

    # Vcluster connect
    vcluster connect my-vcluster-demo -n vcluster-namespace
    ```

5. Nukify

    ```bash
    kubectl --context $PLATFORM delete promise vcluster
    kubectl --context $PLATFORM delete promise jaeger
    ```