FROM gliderlabs/alpine:3.1
RUN apk --update add openjdk7-jre
ENTRYPOINT ["/usr/bin/java", "-Xmx2G", "-Xms1G", "-XX:MaxPermSize=128m", "-jar", "/minecraftserver/forge_latest.jar", "nogui"]
