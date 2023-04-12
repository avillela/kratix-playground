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

RUN echo "Hello6"
# COPY *.yaml ./
# ADD vcluster-setup.sh vcluster-setup.sh

RUN [ "mkdir", "/tmp/transfer" ]
RUN mkdir /root/.kube && touch /root/.kube/config

COPY tester.yaml /tmp/transfer/
COPY namespaces.yaml namespaces.yaml
COPY jaeger.yaml jaeger.yaml
ADD execute-pipeline.sh execute-pipeline.sh
ADD vcluster-setup.sh vcluster-setup.sh

# CMD [ "sh", "-c", "./vcluster-setup.sh"]
CMD [ "sh", "-c", "./execute-pipeline.sh"]
# ENTRYPOINT []
