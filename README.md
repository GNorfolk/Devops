# Vangrant VM installation

## Prerequisites

This installation is based on the expectation that the user is running a mac operating system (OS X) with the basics installed, including git with ssh/http clone functionality, . 

Before you can run this Virtual Machine (VM) you must install Vagrant and Virtual box. You can download [Vagrant here](https://www.vagrantup.com/downloads.html), and [VirtualBox here](https://www.virtualbox.org/wiki/Downloads). Once downloaded you can install them by running the downloaded files which can be found in your downloads folder by default. Once those files are ran, they should provide the information required to complete the installation on your machine. 

## Terminal Commands

Prior to continuing you can check your installation by typing the following into your bash terminal:

``` vagrant ```

This should return some information pertaining to vagrant, if an error is displayed then it has not installed correctly.

### Clone the repo

The first step is cloning the git repository. To do this go to the [github page](https://github.com/GNorfolk/Devops) you should be reading this on and click the green clone or download button. This will provide a link with which to clone the repo in the terminal. For example we will use the SSH method and thus the terminal command will be:

```git clone git@github.com:GNorfolk/Devops.git```

### Initialise Vagrant

Once cloned you should check for a initialization file, ours should be called ```ubuntu-xenial-16.04-cloudimg-console.log```. If you do not have this file, managed to delete it already, or want to rebuild it to fix errors then you can regenerate the file using the following command:

```vagrant init ubuntu/xenial64```

And if you dont want to install this OS into your VM you can find a list of other options [here](https://app.vagrantup.com/boxes/search).

### Install Vagrant dependencies 

To install everything needed for your VM you simply need to run the following command:

```vagrant up```

This will install everything but will also initialize the VM so that it is running in the background. 

### Interacting with the VM

To interact with the VM we must SSH or Secure SHell into it using the following command.

```vagrant ssh ```

This will push the VM's terminal into your own and allow you to interact with the VM via its terminal. 

## Extra information

### Vagrantfile documentation

```# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.10.100"
  config.hostsupdater.aliases = ["development.local"]

end```

This is all the code you will need to start off in your project, but what does it do? 

```config.vm.box = "ubuntu/xenial64"```

This links the VM to the ubuntu OS.

```config.vm.network "private_network", ip: "192.168.10.100"```

This sets the local host directory to be the ip in the quotation marks.

```config.hostsupdater.aliases = ["development.local"]```

This sets http://development.local to link to the ip above and thus the local hosted server.

### Vagrant more commands

There are a few more commands that will be useful.

```exit```

If you type the above in the VM terminal then you will exit the VM terminal and your terminal will revert back to the terminal for your machine.

