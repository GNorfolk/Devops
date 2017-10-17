# Vangrant VM installation

## Prerequisites

This installation is based on the expectation that the user is running a mac operating system (OS X) with the basics installed, including git with ssh/http clone functionality, . 

Before you can run this virtual machine you must install Vagrant and Virtual box. You can download [Vagrant here](https://www.vagrantup.com/downloads.html), and [VirtualBox here](https://www.virtualbox.org/wiki/Downloads). Once downloaded you can install them by running the downloaded files which can be found in your downloads folder by default. Once those files are ran, they should provide the information required to complete the installation on your machine. 

## Terminal Commands

Prior to continuing you can check your installation by typing the following into your bash terminal:

``` vagrant ```

This should return some information pertaining to vagrant, if an error is displayed then it has not installed correctly.

### Clone the repo

The first step is cloning the git repository. To do this go to the [github page](https://github.com/GNorfolk/Devops) you should be reading this on and click the green clone or download button. This will provide a link with which to clone the repo in the terminal. For example we will use the SSH method and thus the terminal command will be:

```git clone git@github.com:GNorfolk/Devops.git```

### Initialise Vagrant

