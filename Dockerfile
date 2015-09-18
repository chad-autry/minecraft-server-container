FROM frolvlad/alpine-oraclejdk8:cleaned
WORKDIR /minecraftserver
ENTRYPOINT ["/usr/bin/java", "-Xmx3G", "-Xms3G", "-jar", "/minecraftserver/forge_latest.jar", "nogui"]
