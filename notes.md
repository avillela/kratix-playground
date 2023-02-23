# Kratix

1. Install

```bash
kubectl apply --filename https://raw.githubusercontent.com/syntasso/kratix/main/distribution/single-cluster/install-all-in-one.yaml

kubectl apply --filename https://raw.githubusercontent.com/syntasso/kratix/main/distribution/single-cluster/config-all-in-one.yaml
```

2. Setup

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

# Convenience tool for grabbing CRD data
# Ref: https://kratix.io/docs/main/guides/writing-a-promise#worker-cluster-resources
curl -sLo worker-resource-builder https://github.com/syntasso/kratix/releases/download/v0.0.1/worker-resource-builder-v0.0.0-1-darwin-arm64
chmod +x worker-resource-builder

# Run convenience tool
./worker-resource-builder \
-k8s-resources-directory ./resources \
-promise ./otelcol-ls-promise-template.yaml > ./otelcol-ls-promise.yaml

# Install the promise
kubectl get pods --namespace kratix-platform-system
```