### Status
[![Build Status](https://travis-ci.org/chad-autry/minecraft-server-container.svg?branch=master)](https://travis-ci.org/chad-autry/minecraft-server-container)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/chadautry/minecraft-server-container/)

## Synopsis

A docker container for running a forge server in the attached disk

Mostly wraps java. Expects the minecraft server jar and world files to come on the provided volume.


## Usage
Expected command to start the server is something like . . .

sudo docker run -d --name mc_server -v /minecraft:/var/minecraft -p 25565:25565 chadautry/minecraft-server-container

Then interact with the server like . . .

sudo docker exec mc_server /bin/sh /var/minecraft/containerizedMinecraftServer.sh exec "say Test"

## Helpful container for setting up a temporary sftp server
sudo docker run -d --name sftp_server -v /minecraft:/home/minecrafter/minecraft -p 2222:22 atmoz/sftp minecrafter:minecrafter:1001

## Mount command I couldn't find on google's docs
From http://stackoverflow.com/questions/23376755/cannot-format-and-mount-disk-on-gce-instance
sudo /usr/share/oem/google-startup-scripts/safe_format_and_mount -m "mkfs.ext4 -F" /dev/disk/by-id/google-persistent-disk-1 minecraft

## The Future
In the early stages yet, hard coded many things

1. Memory Parameters come from command line
2. Kill needs some work, don't think it can kill the shell running at pid 1 like it assumes.
