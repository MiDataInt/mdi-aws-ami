---
title: Tier 1 AMIs
parent: Building AMIs
has_children: false
nav_order: 10
---

## {{page.title}} - base AMIs with Linux and cloned MDI server repos

A Tier 1 base AMI is defined by its Linux operating system. It is created
infrequently to serve as the building block for Tier 2.

## Summary of the base AMI:

- **source AMI** = Ubuntu 22.04 standard image, X86_64
- **Linux user** = ubuntu, the AWS standard
- **region** = Ohio, us-east-2
- **instance type** = t3.medium (2 vCPU, 4 GB RAM)
- **storage** = 8 GB EBS SSD
- **Docker** = installed and ready to build MDI images
- **MDI repositories** = two are cloned into the base AMI itself:
    - <https://github.com/MiDataInt/mdi-aws-ami.git>
    - <https://github.com/MiDataInt/mdi-web-server.git>

### Linux operating system

The MDI can run on any operating system, but we use Ubuntu Linux
by default, with version 22.04 LTS being current as of this writing.

### AWS region

AWS AMIs are region specific, i.e., they are only available to be used
for launching instances in the same region as the AMI itself. We build 
all supported AMIs in the Ohio, us-east-2, AWS region closest to Ann Arbor, MI.

### Instance type

An AMI is not tied to a specific instance type, but we create our 
AMIs with the same resources as is recommended for eventually running
MDI public server instances, i.e., t3 medium.

### Storage

Storage volume size can be expanded when a new EC2 instance is launched,
so instances used to generate MDI AMIs only need enough storage to 
handle the required installations, which is initially modest but increases
when creating Docker images in AMI Tier 2.

### MDI server repositories

As throughout the MDI project, we compartmentalize MDI
public server functions into two distinct repositories:

**MiDataInt/mdi-aws-ami** prepares the base 
AMI for subsequent installation of the MDI. It installs things into the
server OS itself, like Docker. The configuration 
script in this repository could be run on any computer, but the intent 
is that it be run on a fresh Ubuntu AMI on AWS.

**MiDataInt/mdi-web-server** carries code that
configures, assembles, and launches Docker images and containers 
carrying an MDI server installation. Please note that the AMI itself 
does not run the MDI, which is installed into and run in Docker 
containers by scripts found in mdi-web-server.git. 

---
## TIER 1 INSTRUCTIONS - create the base image

We only need to create a base image once per Ubuntu version. Accordingly, the 
steps below are usually only performed by MDI Project administrators. They
clone the mdi-aws-ami repo into a new EC2 instance and run 
the server configuration script to prepare for installing the MDI in later 
tiers/AMIs. 

### Launch an AWS instance

Launch an EC2 instance with the specifications listed above (or, choose
a different base OS or AWS region, if desired).

- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

### Log in to the new instance using an SSH terminal

Details for how to log in to an AWS instance are amply documented by Amazon.
Among many choices, we typically use Visual Studio Code with a remote connection 
established via SSH.

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html>
- <https://code.visualstudio.com/docs/remote/remote-overview>

### Clone this repository

From within an SSH command shell on the new instance 
(note that git is pre-installed with Ubuntu):

```bash
cd ~
git clone https://github.com/MiDataInt/mdi-aws-ami.git
```

### Run the server setup script

```bash
cd mdi-aws-ami
bash ./initialize-mdi-instance.sh
```

It will take a few minutes for all of the server components 
to be installed.

### Security considerations for private base AMI

Base images are generally kept private since general users will start
from a Tier 2, i.e., empty, AMI. Accordingly, no further 
action is required to secure a Tier 1 AMI (unlike Tier 2, below).

### Save the base AMI

From within the [AWS Management Console](https://aws.amazon.com/console/), 
select the running EC2 instance and execute:

Actions --> Images and templates --> Create image

The base image should be named and described according to the following conventions. 
The timestamp can be used to infer the version of the various MDI repos installed into a given server instance.

>**name**  
>mdi-base_ubuntu-22.04_yyyy-mm-dd
>
>**description**  
>Michigan Data Interface, base image, Ubuntu 22.04, yyyy-mm-dd
