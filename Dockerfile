FROM jenkins/jenkins:lts-jdk17

USER root

# Core tooling for CI: git, docker CLI/compose, kubectl, helm
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      docker-cli \
    && rm -rf /var/lib/apt/lists/*

# Docker Compose v2 standalone (Debian trixie doesn't ship docker-compose-plugin)
ARG DOCKER_COMPOSE_VERSION=v2.29.7
RUN curl -fsSL -o /usr/local/bin/docker-compose \
      https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 \
    && chmod +x /usr/local/bin/docker-compose


ARG KUBECTL_VERSION=v1.28.0
RUN curl -fsSL -o /usr/local/bin/kubectl \
      https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

ARG HELM_VERSION=v3.13.0
RUN curl -fsSL -o /tmp/helm.tgz \
      https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/helm.tgz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/helm.tgz /tmp/linux-amd64

# Allow Jenkins user to run docker if /var/run/docker.sock is mounted
#RUN usermod -aG docker jenkins
RUN groupadd -f docker \
    && usermod -aG docker jenkins

USER jenkins

