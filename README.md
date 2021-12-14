# mdi-aws-ami

Admin-only resources to create Amazon Machine Images (AMIs) for 
quickly launching MDI public servers on Amazon Web Services (AWS).

Information on AWS AMIs can be found here:  

<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html>

The AMIs use Docker to install and run the MDI. An introduction to 
Docker can be found here:

<https://www.docker.com/>

## Sequential AMI Plan

AMIs backed by EBS volumes are stored as snapshots that build on each other, 
i.e., later AMIs only store the _changes_ relative to earlier AMIs.
Therefore, we build MDI AMIs sequentially to allow streamlined creation
of later AMIs with appropriate variations.

### AWS vs. Docker images

Please note that the word 'image' is used by both AWS and Docker - do not 
confuse AWS images and Docker images.

Amazon Machine Images (AMIs) represent the installation of a server OS and 
support programs that can be launched as an AWS EC2 instance. These support 
programs include Docker, installed into the MDI base AMI. 

Docker images represent the installation of a server OS and support programs
that can be launched as a Docker container, running on the EC2 instance that
was created by an AMI. Docker images are built in 2nd stage AMIs, e.g., to
allow a new MDI installation based on a new R version release without 
having to reinstall Docker and other base OS support programs.

## STEP 1 - Base AMI with Linux OS and Cloned MDI Server Repos

### Summary of the base AMI:

- **source AMI** = Ubuntu 20.04 standard image, X86_64
- **Linux user** = ubuntu, the AWS standard
- **region** = Ohio, us-east-2
- **instance type** = t3.medium (2 vCPU, 4 GB RAM)
- **storage** = 8 GB EBS SSD
- **Docker** = installed and ready to build MDI images
- **MDI repositories** = two are cloned into the base AMI itself:
    - <https://github.com/MiDataInt/mdi-aws-ami.git>
    - <https://github.com/MiDataInt/mdi-web-server.git>

#### Linux operating system

The MDI can run on any operating system, but we use Ubuntu Linux
by default, with version 20.04 being current as of this writing.

#### AWS region

AWS AMIs are region specific, i.e., they are only available to be used
for launching instances in the same region as the AMI itself. Because
the MDI uses a "Michigan first" approach, we build all AMIs in the
Ohio, us-east-2, AWS region, the one closest to Ann Arbor, MI.

#### Instance type

An AMI is not tied to a specific instance type, but we create the 
AMIs with the same resources as is recommended for eventually running
instances, i.e., t3 medium.

#### Storage

Storage volume size can be adjusted when a new EC2 instance is launched,
so instances used to generate MDI AMIs only need enough storage to 
handle the required installations, which is initially modest but increases
when needing to create large Docker images in Step 2.

#### MDI server repositories

As we do throughout the MDI project, we compartmentalize different MDI
public server functions into two distinct repositories:

**MiDataInt/mdi-aws-ami.git** is the repository that prepares the base 
AMI for subsequent installation of the MDI. It installs things into the
server OS itself, like Docker. Strictly speaking, the configuration 
script in this repository could be run on any computer, but the intent 
is that it be run on a blank, fresh Linux AMI on AWS.

**MiDataInt/mdi-web-server.git** is the repository with code that
configures, assembles, and launches Docker images and containers 
with an MDI server installation. Please note that the AMI itself 
does not run the MDI, instead, the MDI is installed into and run in Docker  
container by scripts found in mdi-web-server.git. 

### Step 1a - create the base image instance

We only need to create a base image once per Ubuntu version. The steps
below will clone this repo into a new EC2 instance and execute the 
server configuration script to prepare for installing the MDI in later 
steps/AMIs. The script prepares the operating system to run the Docker 
images that will run R and the MDI.

#### Launch an AWS instance

Launch an EC2 instance with the specifications listed above (or, choose
a different base OS or AWS region, if desired).

<https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

#### Log in to the new instance using an SSH terminal

Details for how to log in to an AWS instance are amply documented by Amazon.

<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html>

Among many choices, we generally use Visual Studio Code remote connection via SSH:

>https://code.visualstudio.com/docs/remote/remote-overview>

#### Update the OS

From within your terminal, i.e., bash command shell, on the new instance:

```
sudo apt-get update
sudo apt-get upgrade -y
```

#### Install Git

```
sudo apt-get install -y git
```

#### Clone this repository

```
cd ~
git clone https://github.com/MiDataInt/mdi-aws-ami.git
```

#### Run the server setup script

```
cd mdi-aws-ami
sudo bash ./initialize-mdi-instance.sh
```

It will take a few minutes for all of the server components 
to be installed.

#### Save the base AMI

From within the AWS Management Console, select the running
instance and execute:

Actions --> Images and templates --> Create image

The base image should be named by the following conventions:

"Michigan Data Interface, base image, Ubuntu Linux 20.0.4"
