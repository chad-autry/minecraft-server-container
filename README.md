### Status
[![Build Status](https://travis-ci.org/chad-autry/minecraft-server-container.svg?branch=master)](https://travis-ci.org/chad-autry/minecraft-server-container)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/chadautry/minecraft-server-container/)

## Synopsis

This project is all about hosting your own Forge (or Forge Based) MineCraft server in a docker container. 

This README is my attempt at a step by step of how to use the container to host and administer your server.

## Prep
1. First of all to run your MineCraft server you require a computer to host it on. Personally I go with Google Compute Engine, but you could just as eaisly run on Amazon Web Services, or a machine you directlly control.
2. Second, you need to decide on an OS image to use. I went with CoreOS since it is smaller and comes pre-installed with docker, which is what we'll be using.
3. Third, you need a disk or volume to put your game server files on.
   * If you're duplicating my choices, you'll need to pick a disk type and size on GCE. Looking at a 2 player server for a week, it was not very read/write intensive. A 20GB standard disk should give more than enough read/write capacity. There are minitoring tools on the console to double check this and it is easy to size up later. (On GCE your read/write scales with disk size)
   * If you're following along with my choices, I had some issues finding documentation on how to mount my GCE disk on CoreOS. From [StackOverflow](http://stackoverflow.com/questions/23376755/cannot-format-and-mount-disk-on-gce-instance) the command is 
```shell
sudo /usr/share/oem/google-startup-scripts/safe_format_and_mount -m "mkfs.ext4 -F" /dev/disk/by-id/google-disk-1 /minecraft
```
4. Fourth, you need your Forge based server files. Installing Forge is more than this readme will get into, but there are plenty of tutorials out there, such as [this one from Gamepedia](http://minecraft.gamepedia.com/Tutorials/Setting_up_a_Minecraft_Forge_server).
   * Since MineCraft is a Java program, you can simply install the server locally (even on Windows), and then copy the files over for the next step 
5. Fifth, put your MineCraft files over onto the server. There is another container I use to host a temporary FTP server and is usefull for moving files back and forth from your local host. 
```shel
sudo docker run -d --name sftp_server -v /minecraft:/home/minecrafter/minecraft -p 2222:22 atmoz/sftp minecrafter:minecrafter:1001
```
   * Make sure to open port 2222 from your remote server to allow the connection. Make sure to stop and remove the container when you're done.
6. Finally, make a symlink to the Forge server application called forge_latest.jar. Or simply rename it. "forge_latest.jar" is the name the script inside the container will be expecting.
   * Make sure the symlink is relative to the local directory, we'll be mapping the /minecraft directory later and an absolute path won't work

## Start the Server
To start the server we simply execute the command
```shell
sudo docker run -d --name mc_server -v /minecraft:/var/minecraft -p 25565:25565 chadautry/minecraft-server-container
```
* 'sudo' makes the command run as root. This isn't a generally reccomended way of doing things, but it makes the user id consistent between the OS and the docker containers.
* 'docker run' invokes the docker command with its run action
* '-d' is going to put our container in detached mode, so you can close your ssh client and the server will still be running
* '--name mc_server' is naming the container instance so it can be identifed later
* '-v /minecraft/server:/var/minecraft' attaches the directory with our minecraft server files to the location the docker image expects
* '-p 25565:25565' maps the OS port 25565 to the container port 25565.
  * Make sure to open port 25565 from the administration screen
* 'chadautry/minecraft-server-container' is the name of the Docker container image to run. Docker will download it the first time the command is executed.
* Finally, the image itself has an entry point defined as ENTRYPOINT ["/bin/sh", "/usr/bin/containerizedMinecraftServer.sh", "start"] it will start the server automatically inside the container

## Interact with the Server
We can use that same script which started the server to send input to the server's command line. Simply execute the script inside of the already running container like so . . .
```shell
sudo docker exec mc_server /bin/sh /usr/bin/containerizedMinecraftServer.sh exec "say Test"
```
* 'sudo' makes the command run as root. This isn't a generally reccomended way of doing things, but it makes the user id consistent between the OS and the docker containers.
* 'docker exec' invokes docker and tells it to run a command in an already running container
* 'mc_server' is the name given to the MineCraft server container
* Everything following the container name is the command to execute inside the container
  *  '/bin/sh' the shell application which will run our script
  *  '/var/minecraft/containerizedMinecraftServer.sh' the mounted location of the custom utility script
  *  'exec' the action for the script to carry out, it pipes strings to the server's stdin
  *  '"say Test"' the MineCraft server command to execute
. . . and anyone logged in with a MineCraft client should see 'Test' broadcast. "say Test" can be replaced with any other MineCraft commands like give, op, deop, etc.

Similarly we can also stop the server using the script . . .
```shell
sudo docker exec mc_server /bin/sh /usr/bin/containerizedMinecraftServer.sh stop
```
Before you can restart a stopped server, you will need to remove the old container. The container itself didn't have any persistent data (it is all on the attached volume) so it is totally safe to do so.
```
sudo docker rm mc_server
```
## Backing up the Server
Backups are good. Your world data can become corrupt (particularlly when playing modded MineCraft) and without a backup there is no choice other than to start over.

It is possible to backup a server while it is running, without huge impact to users logged on, and without the extra time required to shut down the server.

1. First of all, use the utility script already on the container to stop the server from writting to disk.
```shell
sudo docker exec mc_server /bin/sh /usr/bin/containerizedMinecraftServer.sh saveoff
```
* 'sudo' makes the command run as root. This isn't a generally reccomended way of doing things, but it makes the user id consistent between the OS and the docker containers.
* 'docker exec' invokes docker and tells it to run a command in an already running container
* 'mc_server' is the name given to the MineCraft server container
* Everything following the container name is the command to execute inside the container
  *  '/bin/sh' the shell application which will run our script
  *  '/var/minecraft/containerizedMinecraftServer.sh' the mounted location of the custom utility script
  *  'saveoff' the action for the script to carry out. It pauses writes to the disk.
2. Next run the backup. Use another [container](https://github.com/chad-autry/alpine-rdiff-backup) which wraps [rdiff-backup](http://www.nongnu.org/rdiff-backup/index.html)
```shell
sudo docker run --rm -v /minecraft/world:/var/source -v /minecraft/backups:/var/destination chadautry/alpine-rdiff-backup /var/source /var/destination
```
* 'sudo' makes the command run as root. This isn't a generally reccomended way of doing things, but it makes the user id consistent between the OS and the docker containers.
* 'docker run' invokes the docker command with its run action
* '--rm' will remove the container after it is invoked, so you don't have to
* '-v /minecraft/server:/var/source' attaches the directory with our minecraft server files to the location we will use it
* '-v /minecraft/backups:/var/destination' attaches the directory which contains the backups
  * As written, both the application files and backups are on the same network disk. The backups are intended to protect from MineCraft (or some mods) from corrupting the data. It is not sufficient for hardware failure which the host provider is relied on for. If this was important production data it should be backed up to a different data center. 
* 'chadautry/alpine-rdiff-backup' is the name of the Docker container image to run. Docker will download it the first time the command is executed.
* The image itself has an entry point defined as ENTRYPOINT ["/usr/bin/rdiff-backup"]
* '/var/source /var/destination' the parameters to rdiff-backup. Tells it where to backup from and to.
3. Finally, turn writes to disk back on using
```shell
sudo docker exec mc_server /bin/sh /usr/bin/containerizedMinecraftServer.sh saveon
```
* 'sudo' makes the command run as root. This isn't a generally reccomended way of doing things, but it makes the user id consistent between the OS and the docker containers.
* 'docker exec' invokes docker and tells it to run a command in an already running container
* 'mc_server' is the name of the running MineCraft server container
* Everything following the container name is the command to execute inside the container
  *  '/bin/sh' the shell application which will run our script
  *  '/var/minecraft/containerizedMinecraftServer.sh' the mounted location of the custom utility script
  *  'saveon' the action for the script to carry out. It resumes writes to the disk.

## Timed Backup
Assuming you just leave your server running 24/7, you probablly want it to automatically back up its data every so often
TODO

## Automatically Startup and Save on Shutdown
We're using CoreOS; so lets use systemd to bring the server up when the instance turns on, and safely backup and halt the server when the instance is brought down. Create a file named minecraft.service in /etc/systemd/system and copy these contents into it
```yaml
[Unit]
Description=Minecraft
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker pull chadautry/alpine-rdiff-backup
ExecStartPre=-/usr/bin/docker rm mc_server
ExecStart=/usr/bin/docker run --name mc_server -v /minecraft:/var/minecraft -p 25565:25565 chadautry/minecraft-server-container
ExecStop=/usr/bin/docker exec mc_server /bin/sh /usr/bin/containerizedMinecraftServer.sh exec "say The Virtual Machine is being shut down. Turning off saves and backing up the world." ; /
 /usr/bin/docker exec mc_server /bin/sh /usr/bin/containerizedMinecraftServer.sh saveoff ; /
 /usr/bin/docker run --rm -v /minecraft/world:/var/source -v /minecraft/backups:/var/destination chadautry/alpine-rdiff-backup /var/source /var/destination

[Install]
WantedBy=multi-user.target
```
Then stop the server if it is already running, and execute the commands
```shell
sudo systemctl start minecraft.service
sudo systemctl enable minecraft.service
```

## Monitoring 
TODO