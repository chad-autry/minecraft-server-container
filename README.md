### Status
[![Build Status](https://travis-ci.org/chad-autry/minecraft-server-container.svg?branch=master)](https://travis-ci.org/chad-autry/minecraft-server-container)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/chadautry/minecraft-server-container/)

## Synopsis

A docker container for running a forge server in the attached disk

Mostly wraps java. Expects the minecraft server jar and all other files to come on the provided volume

## Usage
Expected command is something like . . .

sudo docker run -i -t -d -v /minecraft:/minecraftserver -p 25565:25565 chadautry/minecraft-server-container

## The Future
In the early stages yet, hard code many things

1. Memory Parameters come from command line
2. Different components on different attached disks (logs, world, config, mods)
