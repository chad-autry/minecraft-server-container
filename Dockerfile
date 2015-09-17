FROM gliderlabs/alpine:3.1
RUN apk --update add openjdk7-jre
WORKDIR /minecraftserver
ENTRYPOINT ["/usr/bin/java", "-Xmx3G", "-Xms3G", "-XX:MaxPermSize=128m", "-jar", "/minecraftserver/forge_latest.jar", "nogui"]
