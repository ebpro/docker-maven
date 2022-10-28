ARG MAVEN_BASEIMAGE
FROM $MAVEN_BASEIMAGE
RUN apt-get update \
	&& apt-get install -y git wget \
	&& rm -rf /var/lib/apt/lists/*

RUN     wget -cO - https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer > /tmp/s6-overlay-amd64-installer && \
        chmod +x /tmp/s6-overlay-amd64-installer && \
        /tmp/s6-overlay-amd64-installer / && \
        rm /tmp/s6-overlay-amd64-installer && \
        mv /usr/bin/with-contenv /usr/bin/with-contenvb && \
        echo "\e[93m**** Create user & a group 'user' ****\e[38;5;241m" && \
	addgroup --gid 2000 user && \
	adduser --home /home/user --shell /bin/bash --uid 2000 --ingroup user --gecos "" --disabled-password user 


# ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
ENTRYPOINT ["/init"]

COPY /root /

CMD ["mvn"]
