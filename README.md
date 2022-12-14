# Maven extended Docker images

This project provide container images that extend [official maven images](https://hub.docker.com/_/maven).
They are build with [S6 overlay](https://github.com/just-containers/s6-overlay) to provide :
  
- wget
- Git
- Docker client

The easiest way to use it is to define wrapper bash functions in .bashrc ou .zshrc that bind mount the needed directories and sets the UID/GID .

```bash
docker-mvn() (
  docker run --rm -it \
    --env S6_LOGGING=1 \
    --env S6_BEHAVIOUR_IF_STAGE2_FAILS \
    --volume "${HOME}/.m2":"/home/user/.m2" \
    --volume "${HOME}/.ssh":"/home/user/.ssh" \
    --volume "${HOME}/.gitconfig":"/home/user/.gitconfig" \
    --volume "$(pwd)":"/usr/src/mymaven" \
    --workdir /usr/src/mymaven \
    --env PUID="$(id -u)" -e PGID="$(id -g)" \
    --env MAVEN_CONFIG=/home/user/.m2 \
    "${MAVEN_IMAGE:-"brunoe/maven"}" \
    runuser --user user \
    --group user \
    -- mvn --errors --threads 1C --color always --strict-checksums \
    -Duser.home=/home/user \
    "$@"
)

docker-mvn-8() (MAVEN_IMAGE=brunoe/maven:8 docker-mvn $@)
docker-mvn-11() (MAVEN_IMAGE=brunoe/maven:11 docker-mvn $@)
docker-mvn-17() (MAVEN_IMAGE=brunoe/maven:17 docker-mvn $@)
docker-mvn-19() (MAVEN_IMAGE=brunoe/maven:19 docker-mvn $@)
```

It can then used in place of the mvn command without need to installe Java or Maven.

```console
❯ docker-mvn --version
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: /usr/share/maven
Java version: 17.0.5, vendor: Eclipse Adoptium, runtime: /opt/java/openjdk
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.0.11-300.fc37.x86_64", arch: "amd64", family: "unix"

❯ docker-mvn-8 --version
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: /usr/share/maven
Java version: 1.8.0_352, vendor: Temurin, runtime: /opt/java/openjdk/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.0.11-300.fc37.x86_64", arch: "amd64", family: "unix"

❯ docker-mvn-11 --version
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: /usr/share/maven
Java version: 11.0.17, vendor: Eclipse Adoptium, runtime: /opt/java/openjdk
Default locale: en_US, platform encoding: UTF-8

❯ docker-mvn-17 --version
OS name: "linux", version: "6.0.11-300.fc37.x86_64", arch: "amd64", family: "unix"
Apache Maven 3.8.6 (84538c9988a25aec085021c365c560670ad80f63)
Maven home: /usr/share/maven
Java version: 17.0.5, vendor: Eclipse Adoptium, runtime: /opt/java/openjdk
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.0.11-300.fc37.x86_64", arch: "amd64", family: "unix"
```
