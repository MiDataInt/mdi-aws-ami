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
allow a new MDI installation based on a new R version without 
having to reinstall Docker and other base OS support programs.

---
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
MDI public server instances, i.e., t3 medium.

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

### Step 1 Instructions - create the base image

We only need to create a base image once per Ubuntu version. The steps
below will clone the mdi-aws-ami repo into a new EC2 instance and execute  
the server configuration script to prepare for installing the MDI in later 
steps/AMIs. The script prepares the operating system to run the Docker 
images that will run R and the MDI.

#### Launch an AWS instance

Launch an EC2 instance with the specifications listed above (or, choose
a different base OS or AWS region, if desired).

<https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

#### Log in to the new instance using an SSH terminal

Details for how to log in to an AWS instance are amply documented by Amazon.

<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html>

Among many choices, we typically use Visual Studio Code with a remote connection 
established via SSH:

>https://code.visualstudio.com/docs/remote/remote-overview>

#### Clone this repository

From within your terminal, i.e., bash command shell, on the new instance 
(note that git is pre-installed with Ubuntu 20.04):

```
cd ~
git clone https://github.com/MiDataInt/mdi-aws-ami.git
```

#### Run the server setup script

```
cd mdi-aws-ami
bash ./initialize-mdi-instance.sh
```

It will take a few minutes for all of the server components 
to be installed.

#### Save the base AMI

From within the [AWS Management Console](https://aws.amazon.com/console/), 
select the running EC2 instance and execute:

Actions --> Images and templates --> Create image

The base image should be named and described according to these patterns:

**name**  
mdi-aws-ami-base-ubuntu_20.04

**description**  
Michigan Data Interface, base image, Ubuntu Linux 20.04

---
## STEP 2 - Bare bones MDI AMI with pre-built Docker images

### Summary of the bare bones MDI AMI:

- **source AMI** = appropriate Step 1 base AMI, from above
- **instance type** = t3.medium (2 vCPU, 4 GB RAM)
- **storage** = 20 GB EBS SSD
- **Docker images** = pre-built using 'server build'
- **MDI** = installed into Docker volume as frameworks only (no suites):
    - <https://github.com/MiDataInt/mdi-manager.git>
    - <https://github.com/MiDataInt/mdi-pipelines-framework.git>
    - <https://github.com/MiDataInt/mdi-apps-framework.git>

#### Storage

Because R creates a large Docker image size, the EBS volume size
is increased for Step 2 image construction.

#### Docker volumes

Disk storage locations can be confusing. It is important
to remember that R, the MDI manager, frameworks and all associated R
packages are _not_ installed into the base EC2 instance. Instead, they
are installed into the Docker image.

Specifically, all MDI files, including the required R package library,
are installed into a persistent Docker volume that is, generally speaking,
only accessible from within a running container. That volume is addressed
within the container on familiar paths, i.e., /srv/mdi, etc. The data
will be retained by Docker even after containers stop, ready to be 
remounted again when the next container starts.

The 'server' utility function provides access from the EC2 instance
command line to update and modify the MDI installation in the Docker volume. It does this by temporarily launching a new apps-server container.

### Step 2 Instructions - build and install the MDI

We only need to create a bare bones AMI once per R version, since the
Docker images use a specific R version. The AMI image does not need to be recreated
to account for MDI updates as these are always available by re-pulling the appropriate 
repositories.

The steps below will build the required Docker images and use a temporary apps-server
container to install the MDI framework, including its R packages, onto
the appropriate Docker volume.

#### Launch an AWS instance

Launch an EC2 instance with the specifications listed above. Remember, this new
instance must be in the same region as the AMI itself.

<https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

#### Log in to the new instance using an SSH terminal

Please see details above.

#### Specify the R version to use for this build

From within your terminal, i.e., bash command shell, on the new instance:

```
server edit server.sh
```

Change the 'R_VERSION' line as needed, and nothing else.

#### Build the Docker images

```
server build
```

#### Install the bare bones MDI

```
server install
```

It can take a long time, even hours, to fully complete the build and 
install sequence, but it doesn't have to be repeated very often!
Any future build will go much faster.

#### Save the base AMI

From within the [AWS Management Console](https://aws.amazon.com/console/), 
select the running EC2 instance and execute:

Actions --> Images and templates --> Create image

The bare bones image should be named and described according to these patterns:

**name**  
mdi-aws-ami-barebones-ubuntu_20.04-R_4.1.0

**description**  
Michigan Data Interface, bare bones image, Ubuntu Linux 20.04, R 4.1.0

Such images should be made public for anyone to use.

---
## STEP 3 - Add MDI tools suites

Developers providing tools, i.e., Stage 1 Pipelines and Stage 2 Apps, will often
want to create a 3rd sequential image working from the appropriate bare bones image.
The details of such an image will depend on the needs of the developer,
but the following general steps will often be involved:

- **server edit suites.yml**, to specify tools suites to add to the image
- **server install**, to install those new tools suites
- **server edit stage1-pipelines.yml**, to set any needed values for resource installation
- create scripts in /srv/mdi/resource-scripts that will download/create common resources
- **server resource ...**, to download/create the resources

Such provider-specific images should be named and described according to these patterns:

**name**  
mdi-aws-ami-\<provider\>-ubuntu_20.04-R_4.1.0

**description**  
Michigan Data Interface, \<provider\> image, Ubuntu Linux 20.04, R 4.1.0
