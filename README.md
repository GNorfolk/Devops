# Vagrant VM installation

## Prerequisites

This installation is based on the expectation that the user is running a mac operating system (OS X) with the basics installed, including git with ssh/http clone functionality, . 

Before you can run this Virtual Machine (VM) you must install Vagrant and Virtual box. You can download [Vagrant here](https://www.vagrantup.com/downloads.html), and [VirtualBox here](https://www.virtualbox.org/wiki/Downloads). Once downloaded you can install them by running the downloaded files which can be found in your downloads folder by default. Once those files are ran, they should provide the information required to complete the installation on your machine. 

Prior to continuing you can check your installation by typing the following into your bash terminal:

``` vagrant ```

This should return some information pertaining to vagrant, if an error is displayed then it has not installed correctly.

## Terminal Commands

### Clone the repo

The first step is cloning the git repository. To do this go to the [github page](https://github.com/GNorfolk/Devops) you should be reading this on and click the green clone or download button. This will provide a link with which to clone the repo in the terminal. 

For example we will use the SSH method, we need to create a new directory in which to place the VM files and then the terminal command will be:

```git clone git@github.com:GNorfolk/Devops.git```

__ If you dont have your computer setup with SSH data transfer then this wont work! __

Now you need to move into your new directory so make sure you have moved into the folder using the following command: 

``` cd Devops ```

### Install Vagrant dependencies 

To install everything needed for your VM you simply need to run the following command:

```vagrant up```

This will install everything but will also initialize the VM so that it is running in the background. 

__ Congratulations, you now have a functional Virtual Machine! __ 

### Interacting with the VM

To interact with the VM we must SSH or Secure SHell into it using the following command.

```vagrant ssh ```

This will push the VM's terminal into your own and allow you to interact with the VM via its terminal. 

Once inside the VM you will also need to be able to get out of it, which can be done by the following command:

```exit```

If you type the above in the VM terminal then you will exit the VM terminal and your terminal will revert back to the terminal for your machine.

### Vagrant commands

```vagrant destroy```

When typed into your machine's terminal, this will do the opposite of "up" and will stop the VM.

```vagrant reload```

The above will stop the VM and then reload it with any changes you made to the Vagrantfile file. 