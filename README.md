### Status
[![Build Status](https://travis-ci.org/chad-autry/minecraft-server-container.svg?branch=master)](https://travis-ci.org/chad-autry/minecraft-server-container)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/chadautry/minecraft-server-container/)

## Synopsis

This project is all about hosting your own Forge (or Forge Based) MineCraft server in a docker container. 

This README is my attempt at a step by step of how to use the container to host and administer your server.

## Prep
* First of all to run MineCraft you require a server (machine) to host it on. Personally I go with Google Compute Engine, but you could just as eaisly run on Amazon Web Services.
* Second, you need to decide what OS to use. I went with CoreOS since it is smaller and focused on Docker which we're using.
* Third, you need a disk or volume to put your game server files. 
  * If you're following along with me, I had some issues finding documentation on how to mout my GCE disk on CoreOS. From [StackOverflow](http://stackoverflow.com/questions/23376755/cannot-format-and-mount-disk-on-gce-instance) the command is 
```shell
sudo /usr/share/oem/google-startup-scripts/safe_format_and_mount -m "mkfs.ext4 -F" /dev/disk/by-id/google-persistent-disk-1 minecraft
```
* Fourth, you need your server files. This step is way more involved than I'll get into, but download Forge and your mods, or a prexisting pack like Feed the Beast.
* Fifth, put your MineCraft files over onto the server. There is another container I use to host a temporary FTP server and is usefull for moving files back and forth from your local host. 
```shel
sudo docker run -d --name sftp_server -v /minecraft:/home/minecrafter/minecraft -p 2222:22 atmoz/sftp minecrafter:minecrafter:1001
```
Make sure to stop and remove the container when you're done. Make sure to open port 2222 from your remote server to allow the connection.

## Basic Usage
Expected command to start the server is something like . . .

sudo docker run -d --name mc_server -v /minecraft:/var/minecraft -p 25565:25565 chadautry/minecraft-server-container

Then interact with the server like . . .

sudo docker exec mc_server /bin/sh /var/minecraft/containerizedMinecraftServer.sh exec "say Test"

## Backing up the Server
When you make a backup of a minecraft world, you don't want the server to be running. But you don't want to impact your players and totally bring the server down.

## Automatic Restart
TODO

## Monitoring 
TODO

## The Future
In the early stages yet, hard coded many things

1. Memory Parameters come from command line
2. Kill needs some work, don't think it can kill the shell running at pid 1 like it assumes.
