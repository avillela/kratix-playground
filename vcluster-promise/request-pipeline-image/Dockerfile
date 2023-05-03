FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ENV WORKING_DIR="working_dir"
# RUN mkdir -p "${WORKING_DIR}"
# WORKDIR ${WORKING_DIR}

# Install kubectl from Docker Hub
COPY --from=lachlanevenson/k8s-kubectl:v1.25.4 /usr/local/bin/kubectl /usr/local/bin/kubectl

# Install vcluster
RUN curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster

# RUN echo "Hello6"
# COPY *.yaml ./
# ADD vcluster-setup.sh vcluster-setup.sh

# RUN [ "mkdir", "/tmp/transfer" ]
# RUN mkdir /root/.kube && touch /root/.kube/config

# COPY tester.yaml /tmp/transfer/
# COPY namespaces.yaml namespaces.yaml
# COPY jaeger.yaml jaeger.yaml
# ADD execute-pipeline.sh execute-pipeline.sh
# ADD vcluster-setup.sh vcluster-setup.sh

# CMD [ "sh", "-c", "./vcluster-setup.sh"]
# CMD [ "sh", "-c", "./execute-pipeline.sh"]
# ENTRYPOINT []

###########################################################################
# Demo of how to acheive a VCluster that self-registers to Kratix         #
# Once registed, the cluster can get resources scheduled to it by Kratix  #
###########################################################################
# The pipeline script generates a vcluster using Helm templating (in addition to the kubectl and vcluster binaries already installed above)
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh && ./get_helm.sh
# The script uses yq to parse the resource request
RUN curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq
ADD pipeline.sh pipeline.sh
ADD bootstrapper.sh bootstrapper.sh
CMD [ "sh", "-c", "./pipeline.sh"]
