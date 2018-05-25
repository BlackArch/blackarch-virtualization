# Docker Images

## Introduction

This directory includes everything we need to build a Docker image, which is then used to build the actual BlackArch image. This way, we avoid cluttering our environment with build artifacts.

## Requirements

We need a working local Docker client. It is irrelevant to which Docker [engine](https://docs.docker.com/engine/#about-docker-engine) (daemon) the client is connected, though in most cases the engine will be local as well.

## Usage

### Stage 1: `blackarch-builder`

First, we will build an `blackarch-builder` image including everything we need to build the actual `blackarch` image. We then have the `blackarch-builder` image in our Docker engine and start a privileged (because we need to `chroot` in the container) container based on that image. In this container, we mount the Docker control socket which the builder script will later need to import the finished image into the Docker engine. We also mount a local output directory which will hold our final Docker image as a tarball. In most cases, however, having the finished image imported in the Docker engine will suffice.

### Stage 2: The `blackarch` image

When the container based on the `blackarch-builder` starts, the [entrypoint](https://docs.docker.com/engine/reference/builder/#entrypoint) of the image will [pacstrap](https://wiki.archlinux.org/index.php/Install_from_existing_Linux) a minimal Arch Linux installation to a temporary directory (/rootfs-blackarch-XXXXXXXX) under the build directory, perform various configuration steps on that installation (some via a script injected into the chroot, because of some limitations of `arch-bootstrap`), run the BlackArch [`strap.sh`](https://www.blackarch.org/strap.sh) script which in turn will install the BlackArch keys and repositories. Finally, we tar said directory, import that tarball via the Docker control socket into the Docker engine behind the socket, and clean up all temporary files.

### Testing

The `test` target in the `Makefile` will run a container based on the `blackarch` image we previously created and echo `Success.` to prove the image works.

Now we can start BlackArch containers.

    docker run -ti blackarch bash
