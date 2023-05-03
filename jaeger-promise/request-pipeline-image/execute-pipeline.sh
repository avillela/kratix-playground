#!/usr/bin/env sh

set -x

cp /tmp/transfer/* /output/

# Generate the namespace we want jaeger installed into
cat > /output/namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: opentelemetry
EOF

echo $(yq eval '.spec.clusterSelectors' /input/object.yaml) > /metadata/cluster-selectors.yaml
