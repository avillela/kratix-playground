# OTel Operator for Jaeger

This creates and installs an OTel Operator configured to send traces to [Jaeger](https://jaegertracing.io). It also deploys a sample Go service so that you can test your connectivity.

1. Install Kratix

    Single-cluster install and configure (i.e. control and worker are on the same cluster).

    ```bash
    # Install
    kubectl apply --filename https://raw.githubusercontent.com/syntasso/kratix/main/distribution/single-cluster/install-all-in-one.yaml

    # Configure
    kubectl apply --filename https://raw.githubusercontent.com/syntasso/kratix/main/distribution/single-cluster/config-all-in-one.yaml
    ```

2. Create scaffolding

    Create basic directory structure for promise and create a template for our promise

    ```bash
    # Scaffolding
    mkdir -p oteloperator-promise/request-pipeline-image/{input,output}

    # Create template
    tee -a oteloperator-promise/promise-template.yaml <<EOF
    apiVersion: platform.kratix.io/v1alpha1
    kind: Promise
    metadata:
        name: oteloperator
    spec:
        workerClusterResources:
        xaasRequestPipeline:
        xaasCrd:
    EOF
    ```

3. Define promise API

    Kratix docs ref [here](https://kratix.io/docs/main/guides/writing-a-promise#promise-api)

    ```bash
    # Append CRD definition to end of file
    tee -a oteloperator-promise/promise-template.yaml <<EOF
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: oteloperators.example.promise
        spec:
          group: example.promise
          scope: Namespaced
          names:
            plural: oteloperators
            singular: oteloperator
            kind: oteloperator
          versions:
          - name: v1
            served: true
            storage: true
            schema:
              openAPIV3Schema:
                type: object
                properties:
                  spec:
                    type: object
                    properties:
                      name:
                        type: string
    EOF
    ```

4. Define `workerClusterResources`

    First, download the OTel Collector CRD

    ```bash
    curl -L https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.73.0/opentelemetry-operator.yaml -o oteloperator-promise/resources/opentelemetry-operator.yaml
    ```

    Next, download and run the [`worker-resource-builder` tool](https://kratix.io/docs/main/guides/writing-a-promise#worker-cluster-resources). This tool grabs the CRD contents and plunks them into the `workerClusterResources` section of the promise YAML.

    ```bash
    # Download the resource builder tool
    curl -sLo worker-resource-builder https://github.com/syntasso/kratix/releases/download/v0.0.1/worker-resource-builder-v0.0.0-1-darwin-arm64

    chmod +x worker-resource-builder

    # Run the resource builder tool
    ./worker-resource-builder \
    -k8s-resources-directory ./oteloperator-promise/resources \
    -promise ./oteloperator-promise/promise-template.yaml > ./oteloperator-promise/promise.yaml
    ```

5. Define your pipeline

   Kratix docs ref [here](https://kratix.io/docs/main/guides/writing-a-promise#pipeline-script)

   ```bash
   tee -a oteloperator-promise/request-pipeline-image/execute-pipeline.sh <<EOF
     #!/bin/sh

     set -x

     cp /tmp/transfer/* /output/
   EOF

   chmod +x oteloperator-promise/request-pipeline-image/execute-pipeline.sh
   ```

   Build and test the pipeline

   ```bash
   docker build -t oteloperator-request-pipeline:dev ./oteloperator-promise/request-pipeline-image/
   ```

   Create sample `object.yaml`

   ```bash
   tee -a oteloperator-promise/request-pipeline-image/input/object.yaml <<EOF
      apiVersion: promise.example.com/v1
      kind: otelcol
      metadata:
        name: my-otelcol-promise-request
      spec:
        name: my-amazing-otelcol
   EOF
   ```

   Run container and examine the output

   ```bash
   docker run -v $PWD/oteloperator-promise/request-pipeline-image/input:/input -v $PWD/oteloperator-promise/request-pipeline-image/output:/output oteloperator-request-pipeline:dev
   ```

   Push to Docker registry

   ```bash
   docker buildx build --push -t ghcr.io/$GH_USER/oteloperator-request-pipeline:dev --platform=linux/arm64,linux/amd64 ./oteloperator-promise/request-pipeline-image/
   ```

6. Install the promise

    ```bash
    # Install dependent promise (Cert Manager)
    kubectl create -f https://raw.githubusercontent.com/syntasso/kratix-marketplace/main/cert-manager/promise.yaml
    
    # Install OTel Collector Promise
    kubectl apply -f oteloperator-promise/promise.yaml

    # Make sure that promises are installed
    kubectl get promises

    # Check CRD installations
    kubectl get crds --watch | grep otelcol

    # Some other commands to make sure stuff works
    kubectl get pods --namespace kratix-platform-system
    kubectl get kustomizations -A -w
    kubectl get certificates -A

    # Kratix controller manager log
    ./scripts/manager-logs.sh
    ```

7. Request the resource

   ```bash
   # Run the resource request
   kubectl apply -f oteloperator-promise/oteloperator-resource-request.yaml
   ```

   Check flux status

   ```bash
   ./scripts/flux-status.sh
   ```

8. Verify

   ```bash
   # Port-forwarding
   kubectl port-forward -n application svc/otel-go-server-svc 9000:9000
   kubectl port-forward -n opentelemetry svc/jaeger-all-in-one-ui 16686:16686

   # Run the app
   curl http://localhost:9000

   # Sample app logs
   kubectl logs --selector=app=otel-go-server-example -n application --follow

   # Collector logs
   kubectl logs -l app=opentelemetry -n opentelemetry --follow

   # Promise request logs
   kubectl logs --selector=kratix-promise-id=oteloperator-default --container status-writer

   kubectl logs --selector=kratix-promise-id=oteloperator-default --container xaas-request-pipeline-stage-1
   ```

## Cleanup

This will delete all namespaces, resources, and promise request.

```bash
kubectl delete promise otelcol
```