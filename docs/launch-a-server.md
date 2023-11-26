---
title: Launch a Web Server
has_children: false
nav_order: 30
---

## {{ page.title }}

These instructions assume you have followed documentation from external sources to
[establish an AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html),
and that you know what MDI tool suites whose apps you wish to use.

They further assume you have authority in your account and basic familiarity with establishing
[AWs EC2 instances](https://aws.amazon.com/pm/ec2) and establishing a connection to them via SSH.
If you don't already have a preference, we recommend using [VS Code](https://code.visualstudio.com/)
as described in our [Basic Training](https://midataint.github.io/mdi-basic-training/docs/code-editor/).

### Launch a server instance from a Tier 2 or Tier 3 AMI

You will nearly always want to launch your MDI web server instance on AWS
using one of the pre-built Tier 2 or Tier 3 AMIs, which is much faster, more efficient,
and less confusing for beginners. Choose a Tier 2 AMI if you need to list the tool suites yourself,
or a Tier 3 AMI if one was provided to you by a tool suite developer.

Here is the link to the MDI public AMIs where you will find a suitable Tier 2 AMI (you need to log in to 
AWS for this link to work as expected):
- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;v=3;search=:Michigan%20Data%20Interface>

Once you have found the AMI, simply launch an instance from it.  Adjust the instance size and capacity as suits 
your needs, with the following guidance:
- t3.small instances are acceptable for limited use servers
- t3.medium instances are best for routine use among a lab group
- ~30 GB RAM is suitable for moderate data needs, or if you will mount a data file system

### Point your DNS to your new server instance

Use [AWS Route 53](https://aws.amazon.com/route53/) to establish a DNS record in your web domain 
that points to the IP address assigned to your new instance.
You may choose to assign a reserved 
[Elastic IP Address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) 
to the server but it is not necessary. Just
be aware that if you stop your instance without an elastic IP it will be assigned a new IP
when you restart it, requiring modification of your DNS record. 

### Learn the basic server file structure

Log into the server using the SSH key you specified when you launched the instance.

Once logged in, navigate to the folder that carries all the server files:

```sh
cd /srv
ls -l

total 12
drwxrwxr-x 2 ubuntu mdi-edit 4096 Nov 21 18:12 data
drwxrwxr-x 6 ubuntu mdi-edit 4096 Nov 24 13:17 mdi
drwxr-xr-x 3 root   root     4096 Nov 23 17:44 mnt
```

Folder `mdi` carries the `mdi-web-server` installation,
folders `data` and `mnt` are where you will upload MDI data packages 
and other required data resources.

### Use the command line utility to manage your server

The `mdi-web-server` repository provides a convenient command line
management utility that will help you perform all required server
tasks without needing deep familiarity with Docker, R
or other server components. Simply type `server` to get started.

```sh
server

usage:  ./server <COMMAND> ...

server execution commands (in order of usage):
    upgrade   use apt to install all updated system libraries and security patches
    edit      use nano to edit one of the server configuration files
    build     run docker compose build to create all needed Docker images
    install   update the server config, clone GitHub repos, install R packages
    up        launch all containers to run the MDI apps server
    ls        list all stored Docker images and running containers
    update    copy updated config files into server containers without reinstalling
    down      stop and remove any running containers to shut down the apps server

additional resource management commands:
    resource  run a script to download/install data into the permanent Docker volume
    bash      bring up an interactive bash terminal in a new apps-server container
```

The sub-commands are named informatively and hopefully with the brief 
descriptions it will be apparent what each one does. You may want
to refamiliarize yourself with the 
[web server structure](https://midataint.github.io/mdi-aws-ami/docs/server-structure.html)
if not clear.

Importantly, the `server` subcommands are presented in logical order of their
usage to get your server up and running. Start from the top and work down!

### Server configuration files

The `edit` command will bring up the nano text editor so that you can
edit one of the following required or optional configuration files.

```sh
server edit

usage:  ./server edit <CONFIG_FILE>

where CONFIG_FILE is one of:
    server.sh             server configuration metadata
    suites.yml            tool suites to install
    stage2-apps.yml       access control options for the apps server
    mount.sh              optional commands to mount external file systems to /srv/mnt/...
```

Advanced users will probably find it easier to just edit the config files
from within VS Code. They are all found under directory `/srv/mdi/config`.

As with the `server` sub-commands, we will not provide detailed additional
documentation here because each configuration file has detailed comments
to help you fill them in properly. Briefly, you will use the files to:
- describe your server
- establish a secure login approach
- declare the tool suites you wish to use

Also, the trickiest bits regarding server security and file paths
are documented in detail in the `mdi-apps-framework`, since some apply
to non-public servers as well:

- <https://midataint.github.io/mdi-apps-framework/docs/server-deployment/server-security.html>
- <https://midataint.github.io/mdi-apps-framework/docs/server-deployment/shinyFiles.html>
