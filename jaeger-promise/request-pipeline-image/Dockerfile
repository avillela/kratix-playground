FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# The script uses yq to parse the resource request
RUN curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq

RUN [ "mkdir", "/tmp/transfer" ]
ADD jaeger.yaml /tmp/transfer/jaeger.yaml
ADD execute-pipeline.sh execute-pipeline.sh

CMD [ "sh", "-c", "./execute-pipeline.sh"]
