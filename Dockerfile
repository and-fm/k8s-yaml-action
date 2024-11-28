FROM alpine/curl:latest

# Install kubectl
RUN curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /bin/kubectl
RUN chmod +x /bin/kubectl

# Install yq
RUN curl -L "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" -o /bin/yq
RUN chmod +x /bin/yq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]