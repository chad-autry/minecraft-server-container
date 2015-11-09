FROM frolvlad/alpine-oraclejdk8:cleaned
COPY containerizedMinecraftServer.sh /usr/bin/containerizedMinecraftServer.sh
RUN chmod +x /usr/bin/containerizedMinecraftServer.sh
WORKDIR /var/minecraft
ENTRYPOINT ["/bin/sh", "/usr/bin/containerizedMinecraftServer.sh", "start"]
