# Packer.io Template

## Introduction

In this repo you find everything you need to generate a Vagrant basebox of BlackArch. We install a minimal ArchLinux and then add BlackArch on top via [`strap.sh`](https://github.com/BlackArch/blackarch-site/blob/master/strap.sh).
This is based on the [GPL-licenced](https://github.com/kornrunner/packer-arch/blob/12748faaa76933281046cc5206c59436ffd75434/LICENSE) [kornrunner/packer-arch](https://github.com/kornrunner/packer-arch/tree/12748faaa76933281046cc5206c59436ffd75434).

## Prerequisites

* [`aur/packer-io`](https://aur.archlinux.org/packages/packer-io/)
* [`community/vagrant`](https://www.archlinux.org/packages/community/x86_64/vagrant/)
* [`community/virtualbox`](https://www.archlinux.org/packages/community/x86_64/virtualbox/) including [host modules](https://wiki.archlinux.org/index.php/VirtualBox#Load_the_VirtualBox_kernel_modules)

## Usage

All actions are implemented as `make` targets.

* *clean*: clean output directories
* *deepclean*: clean output directories and Packer cache
* *validate*: validate the template JSON
* *test*: run rudimentary tests against a built image
* *build*: build image

A typical build can be triggered with

    make clean build test
