  #!/bin/sh

  set -x

  #Get the name from the Promise Custom resource
  instanceName=$(yq eval '.spec.name' /input/object.yaml)

  # Inject the name into the resources
  find /tmp/transfer -type f -exec sed -i \
    -e "s/<tbr-name>/${instanceName//\//\/}/g" \
    {} \;

  cp /tmp/transfer/* /output/
