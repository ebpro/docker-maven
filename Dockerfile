ARG MAVEN_BASEIMAGE=maven:latest
FROM $MAVEN_BASEIMAGE

ENV DOCKER_CLIENT_VERSION=20.10.19
ENV DOCKER_COMPOSE_VERSION=2.13.0

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
        apt-get update \
	&& apt-get install -y git wget \
	&& rm -rf /var/lib/apt/lists/*

RUN     wget -cO - https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer > /tmp/s6-overlay-amd64-installer && \
        chmod +x /tmp/s6-overlay-amd64-installer && \
        /tmp/s6-overlay-amd64-installer / && \
        rm /tmp/s6-overlay-amd64-installer && \
        mv /usr/bin/with-contenv /usr/bin/with-contenvb && \
        echo "\e[93m**** Create user & a group 'user' ****\e[38;5;241m" && \
	addgroup --gid 2000 user && \
	adduser --home /home/user --shell /bin/bash --uid 2000 --ingroup user --gecos "" --disabled-password user && \
	touch /home/user/.gitconfig && chown user: /home/user/.gitconfig #.gitconfig must be created for bind mount as it is a file and not a directory.

RUN echo "\e[93m**** Installing docker client ${DOCKER_CLIENT_VERSION} ****\e[38;5;241m" && \
    curl -sL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLIENT_VERSION}.tgz" | \
      tar --directory="/usr/bin/" --strip-components=1 -zx docker/docker && \
      chmod +x "/usr/bin/docker" && \
      echo "\e[93m**** Installing docker compose plugin ${DOCKER_COMPOSE_VERSION} ****\e[38;5;241m" && \
      mkdir -p /home/user/.docker/cli-plugins/ && \
      curl -sL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
        -o /home/user/.docker/cli-plugins/docker-compose && \
      chmod +x /home/user/.docker/cli-plugins/docker-compose

ENTRYPOINT ["/init"]

COPY /root /

CMD ["mvn"]
