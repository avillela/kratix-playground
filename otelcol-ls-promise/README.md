# OTel Collector for Lightstep Promise

This creates and installs an OTel Collector configured to send traces to [Lightstep Observability](https://app.lightstep.com).

1. Install Kratix

    Single-cluster install and configure (i.e. control and worker are on the same cluster).

    ```bash
    # Install
    kubectl apply --filename https://raw.githubusercontent.com/syntasso/kratix/main/distribution/single-cluster/install-all-in-one.yaml

    # Configure
    kubectl apply --filename https://raw.githubusercontent.com/syntasso/kratix/main/distribution/single-cluster/config-all-in-one.yaml
    ```

2. Create scaffolding

    Creates basic directory structure for promies and creates a template for our promise

    ```bash
    # Scaffolding
    mkdir -p otelcol-ls-promise/{resources,request-pipeline-image}
    cd otelcol-ls-promise

    # Create template
    tee -a otelcol-ls-promise-template.yaml <<EOF
    apiVersion: platform.kratix.io/v1alpha1
    kind: Promise
    metadata:
      name: otelcol-ls
    spec:
      workerClusterResources:
      xaasRequestPipeline:
      xaasCrd:
    EOF
    ```

3. Define promise API

    Kratix docs ref [here](https://kratix.io/docs/main/guides/writing-a-promise#promise-api)

    ```bash
    # Append CRD to end of file
    tee -a otelcol-ls-promise-template.yaml <<EOF
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: otelcol.example.promise
        spec:
          group: otelcol.example.promise
          scope: Namespaced
          names:
            plural: otelcol
            singular: otelcol
            kind: otelcol
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
    curl -L https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.70.0/opentelemetry-operator.yaml > resources/opentelemetry-operator.yaml
    ```

    Next, download and run the [`worker-resource-builder` tool](https://kratix.io/docs/main/guides/writing-a-promise#worker-cluster-resources). This tool grabs the CRD contents and plunks them into the `workerClusterResources` section of the promise YAML.

    ```bash
    curl -sLo worker-resource-builder https://github.com/syntasso/kratix/releases/download/v0.0.1/worker-resource-builder-v0.0.0-1-darwin-arm64
    chmod +x worker-resource-builder

    # Run convenience tool
    ./worker-resource-builder \
    -k8s-resources-directory ./resources \
    -promise ./otelcol-ls-promise-template.yaml > ./otelcol-ls-promise.yaml
    ```

5. Define your pipeline

   Need to add stuff here.

6. Install the promise

    ```bash
    # Install dependent promise (Cert Manager)
    kubectl create -f https://raw.githubusercontent.com/syntasso/kratix-marketplace/main/cert-manager/promise.yaml
    
    # Install OTel Collector Promise
    kubectl apply -f otelcol-ls-promise/promise.yaml

    # Check if promises are installed
    kubectl get promises

    # Check CRD installations
    kubectl get crds --watch | grep otelcol

    # Some other commands to see if stuff works
    kubectl get pods --namespace kratix-platform-system
    kubectl get kustomizations -A -w
    kubectl get certificates
    ```