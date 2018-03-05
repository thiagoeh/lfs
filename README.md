# My journey through Linux From Scratch (LFS)
This doesn't intend to be a guide on the [LFS book](http://www.linuxfromscratch.org/lfs/view/stable), but much more a place to take notes of the steps taken that aren't provided in the book itself.

My physical machine runs Ubuntu 16.04, and I didn't want to install all the LFS base system in this host.

As I also wanted to become more confortable in the use of Vagrant, and maybe event automate the first steps of LFS through it, I've decided to use Vagrant to create a dedicated VM for LFS.

I chosed Debian as the base host for LFS because is the distro that I'm more confortable, and I didn't want to learn how to use another package management system during the LFS journey.

## Choosing a boot/services manager

There are two stable editions of the LFS: the _classical_ one uses `SysVinit` to manage the booting, and there is an alternative with `systemd`.

Even though I agree with the criticism that `systemd` is too complex and out of the unix philosofy, it is the defacto services manager in both RHEL and Debian (and respective derivatives). Because of this I will follow the `systemd` edition to be able to know more about the usage of it.

If this were a LFS build more focused in continuous usage (instead of learning) I probably would stick with SysVinit, or maybe experiment with OpenRC.


## Creating and running a dedicated VM for LFS using Vagrant
A basic Debian VM will be the starting point where the system requirements for LFS will be installed.
Vagrant (and VirtualBox) must be already installed.

```bash
# Creating a dedicated directory for the LFS vm
mkdir lfs_vm
cd lfs_vm

# this puts a Vagrantfile in the lfs_vm folder, pointing to a debian-stretch "box"
vagrant init debian/contrib-stretch64

# the Debian image will be automatically downloaded at the first run of this command, and kept in the boxes cache
vagrant up 

# connects to the VM through SSH
vagrant ssh 
```

The [`Vagrantfile`](Vagrantfile) created by the command `vagrant init debian/contrib-stretch64` is available at this repository, but currently it's just the default content.

After being connected to the VM I updated the system using APT
```bash
apt update
apt upgrade --yes
```

## Installing the host requirements at the VM

The first practical step from the LFS book is the installation of the [software requirements](http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter02/hostreqs.html) in the base system (the Debian VM).

Instead of manually checking the requirements, I ran the `version-check.sh` script and checked the messages that it spit out.

```bash
$ ./version-check.sh 
bash, version 4.4.12(1)-release
/bin/sh -> /bin/dash
ERROR: /bin/sh does not point to bash
```
There is an [explanation of why Debian (and Ubuntu)](https://wiki.debian.org/DashAsBinSh) are pointing `/bin/sh` to `/bin/dash`. As we are in a dedicated VM for LFS, let's simply change the link back to bash:
```bash
sudo rm /bin/sh
sudo ln -s /bin/bash /bin/sh
```
Running `version-check.sh` again pointed at some missing software. 
This was fixed with the following packages:
```bash
sudo apt install bison gawk g++ texinfo
```

`Bison`, `gawk` and `g++` could be identified directly. `texinfo` provides the `makeinfo` requirement.

Most software at the host is not exactly in the same version, but all the hard requirements (not using newer than XX) are being met.


