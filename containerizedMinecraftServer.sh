#!/bin/sh

#A shell script to run inside a docker container to start a minecraft server.
#Has further methods to allow the server to be manipulated using docker exec commands from outside of the container.

# Settings start
SERVICE='/var/minecraft/forge_latest.jar'

MEMORY_OPTS="-Xmx6.5G -Xms6.5G"

INVOCATION="/usr/bin/java ${MEMORY_OPTS} -jar $SERVICE nogui"

#Port 25565 is the port which should be exposed
PORT=25565


# Settings end


# Dockerized server script, it is PID 1. This really just checks that the command is running as docker exec


mc_start() {
    #Create a fifo to act as the server's stdin
    mkfifo /tmp/srv-input

    #finally start the server, By tailing the fifo and piping it to the stdin, we avoid any EOF and automatically get newline characters.
    tail -f /tmp/srv-input | /usr/bin/java ${MEMORY_OPTS} -jar $SERVICE nogui
}

mc_saveoff() {

    echo "Suspending saves"
    mc_exec "say SERVER BACKUP STARTING. Server going readonly..."
    mc_exec "save-off"
    mc_exec "save-all"
    sync
    sleep 10

}

mc_saveon() {
    echo "Re-enabling saves"
    mc_exec "save-on"
    mc_exec "say SERVER BACKUP ENDED. Server going read-write..."
}

mc_kill() {

    echo "Terminating the primary container process with pid 1"
    kill 1

    #If the primary containerized process dies, then any process execed in the container should too. No need to check for liveness

    sleep 10

    echo "$SERVICE could not be terminated, killing..."
    kill -SIGKILL 1
    echo "$SERVICE killed"
}

mc_stop() {
    mc_exec "say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map..."
    mc_exec "save-all"
    sleep 10
    mc_exec "stop"

    #Could write a complicated loop or something and check if the service is alive...just wait the max of 10 seconds we expect this to take
    sleep 10

    #The tail which is piping our input hangs around, keeping the primary process alive, until it attempts to write something and sees the pipe is broken
    #If the primary containerized process dies, however, then any process execed in the container (like this one) should too. No need to check for liveness
    for i in 'seq 0 9'
    do
        mc_exec "say $i"
        sleep 1
    done

    echo "$SERVICE could not be shut down cleanly... still running."
    mc_kill
}

mc_exec() {
    if [ -e /tmp/srv-input ]; then
        echo "$@" > /tmp/srv-input
    else
        echo "/tmp/srv-input did not exist to write to"
    fi
}


#Start-Stop here
case "$1" in
  start)
    mc_start
    ;;
  stop)
    mc_stop
    ;;
  exec)
    shift
    mc_exec "$@"
    ;;
  saveoff)
    mc_saveoff
    ;;
  saveon)
    mc_saveon
    ;;

  *)
  echo "Usage: $(readlink -f $0) {start|stop|exec|saveoff|saveon}"
  exit 1
  ;;
esac

exit 0
