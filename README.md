# mdi-aws-ami

Admin-only resource to create Amazon Machine Images (AMIs) for 
quickly launching Michigan Data Interface (MDI) public web servers 
on Amazon Web Services (AWS). Information on AWS AMIs can be found here:  

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html>

The AMIs use Docker to install and run the MDI.

- <https://www.docker.com/>

## Sequential AMI Plan

AMIs backed by EBS volumes are stored as snapshots that build on each other, 
i.e., later AMIs only store the changes relative to earlier AMIs.
We build MDI AMIs sequentially to allow streamlined creation
of later AMIs.

### AWS vs. Docker images

The word 'image' is used by both AWS and Docker - do not 
confuse AWS images and Docker images.

Amazon Machine Images (AMIs) represent the installation of a server OS and 
support programs that can be launched as an AWS Elastic Cloud Computings (EC2) 
instance. These support programs include Docker, installed into the MDI Tier 1,
i.e., base AMI. 

Docker images represent the installation of a server OS and support programs
that can be launched as a Docker container, running on the EC2 instance that
was created by an AMI. Docker images are built in Tier 2 AMIs, e.g., to
allow a new MDI installation based on a new R version without 
having to reinstall Docker and other base OS support programs.

---
---
## AMI TIER #1 - Base AMI with Linux and Cloned MDI Server Repos

### Summary of the base AMI:

- **source AMI** = Ubuntu 22.04 standard image, X86_64
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
by default, with version 22.04 LTS being current as of this writing.

#### AWS region

AWS AMIs are region specific, i.e., they are only available to be used
for launching instances in the same region as the AMI itself. We build 
all supported AMIs in the Ohio, us-east-2, AWS region closest to Ann Arbor, MI.

#### Instance type

An AMI is not tied to a specific instance type, but we create our 
AMIs with the same resources as is recommended for eventually running
MDI public server instances, i.e., t3 medium.

#### Storage

Storage volume size can be expanded when a new EC2 instance is launched,
so instances used to generate MDI AMIs only need enough storage to 
handle the required installations, which is initially modest but increases
when creating Docker images in AMI Tier 2.

#### MDI server repositories

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
### TIER 1 INSTRUCTIONS - create the base image

We only need to create a base image once per Ubuntu version. Accordingly, the 
steps below are usually only performed by MDI Project administrators. They
clone the mdi-aws-ami repo into a new EC2 instance and run 
the server configuration script to prepare for installing the MDI in later 
tiers/AMIs. 

#### Launch an AWS instance

Launch an EC2 instance with the specifications listed above (or, choose
a different base OS or AWS region, if desired).

- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

#### Log in to the new instance using an SSH terminal

Details for how to log in to an AWS instance are amply documented by Amazon.
Among many choices, we typically use Visual Studio Code with a remote connection 
established via SSH.

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html>
- <https://code.visualstudio.com/docs/remote/remote-overview>

#### Clone this repository

From within an SSH command shell on the new instance 
(note that git is pre-installed with Ubuntu):

```bash
cd ~
git clone https://github.com/MiDataInt/mdi-aws-ami.git
```

#### Run the server setup script

```bash
cd mdi-aws-ami
bash ./initialize-mdi-instance.sh
```

It will take a few minutes for all of the server components 
to be installed.

#### Security considerations for private base AMI

Base images are generally kept private since general users will start
from a Tier 2, i.e., empty, AMI. Accordingly, no further 
action is required to secure a Tier 1 AMI (unlike Tier 2, below).

#### Save the base AMI

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

---
---
## AMI TIER #2 - Empty MDI AMI with pre-built Docker images

### Summary of the empty MDI AMI:

- **source AMI** = appropriate Tier 1 base AMI, from above
- **instance type** = t3.xlarge (4 vCPU, 16 GB RAM)
- **storage** = 20 GB EBS SSD
- **Docker images** = pre-built using 'server build'
- **MDI** = installed into Docker volume as frameworks only (no tool suites):
    - <https://github.com/MiDataInt/mdi-manager.git>
    - <https://github.com/MiDataInt/mdi-pipelines-framework.git>
    - <https://github.com/MiDataInt/mdi-apps-framework.git>

#### Storage

Because R creates a large Docker image size, the EBS volume size
is increased for Tier 2 image construction.

#### Docker volumes

Disk storage locations can be confusing. 
R, the MDI manager, frameworks, and all associated R
packages are _not_ installed into the base EC2 instance file tree. Instead, they
are installed into the Docker image.

Specifically, all MDI files, including the required R package library,
are installed into a persistent Docker volume that is
only accessible from within a running container. That volume is addressed
within the container on familiar paths, i.e., /srv/mdi, etc. The data
in the volume is retained by Docker after containers stop, ready to be 
remounted again when the next container starts.

The 'server' utility function provides access from the EC2 instance
command line to update and modify the MDI installation in the Docker volume. It does this by temporarily launching a new apps-server container with access to the volume.

---
### TIER 2 INSTRUCTIONS - build and install the MDI

We only need to create an empty AMI once per R version, since the
Docker images use a specific R version. The AMI image does not need to be 
recreated to account for MDI updates as these are always available by 
re-pulling the appropriate repositories. Accordingly, the steps below are 
usually only performed by MDI Project administrators. They build the required 
Docker images and use a temporary apps-server container to install the MDI framework
and R packages onto the appropriate Docker volume.

#### Launch an AWS instance

Launch an EC2 instance with the specifications listed above. Remember, this new
instance must be in the same region as the AMI itself.

- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

#### Log in to the new instance using an SSH terminal

Please see details above.

#### Specify the R version to use for this build

From within a terminal, i.e., bash command shell, on the new instance:

```
server edit server.sh
```

Change the 'R_VERSION' line as needed, and nothing else.

#### Build the Docker images

```bash
server build
```

#### Install the empty MDI

```bash
server install
```

It takes a while to fully complete the build and 
install sequence, but it doesn't have to be repeated very often.
Any future build will go much faster.

#### Secure the empty AMI for public distribution

Empty server images should be made public for anyone to use by
setting the Permissions in the AWS console after creating the AMI. 
In preparation for this public release, we follow the AWS guidelines
for securing shared AMIs:

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/building-shared-amis.html>

Specifically, immediately before creating the AMI, run the following script, 
which removes ssh keys and restricts root login permissions:

```bash
bash ~/mdi-aws-ami/prepare-public-ami.sh
```

If the sequence above was followed, there will be no other keys or access 
tokens on the disk to be copied into the image.

Once the commands above are executed, the 
instance from which the Tier 2 AMI is created will not be accessible
after it is stopped - just launch a new instance from the saved AMI.

#### Save the empty AMI

From within the [AWS Management Console](https://aws.amazon.com/console/), 
select the running EC2 instance and execute:

Actions --> Images and templates --> Create image

The empty image should be named and described according to the following conventions. 

>**name**  
>mdi-empty_ubuntu-22.04_R-4.2.0_yyyy-mm-dd
>
>**description**  
>Michigan Data Interface, empty server image, Ubuntu 22.04, R 4.2.0, yyyy-mm-dd

---
---
## AMI TIER #3 - Add publicly released MDI tools suites

Developers providing tools for others to use
should create a 3rd sequential AMI tier working from the appropriate empty image.
The details of such an image will depend on the needs of the developer,
but the following general steps will typically be needed:

- **server edit suites.yml**, to specify tools suites to add to the image
- **server install**, to install those new tools suites

Additionally, some tool providers may wish to include data resources in their image,
which might be installed by actions such as:

- create/clone scripts into **/srv/mdi/resource-scripts** that will install common resources
- **server resource ...**, to download/create the resources

#### Secure the provider AMI for public distribution

Most often, provider AMIs should be made public for easy access by all users.
Accordingly, please follow the instructions above for Tier 2 AMIs to
secure your provider AMI for public release by running the following script.

```bash
bash ~/mdi-aws-ami/prepare-public-ami.sh
```

#### Save the provider AMI

Provider-specific images should be named and described according to the following conventions. 

>**name**  
>mdi-\<provider\>_ubuntu-22.04_R-4.2.0_yyyy-mm-dd
>
>**description**  
>Michigan Data Interface, \<provider\> server image, Ubuntu Linux 22.04, R 4.2.0, yyyy-mm-dd

---
---
## INSTANCE TIER #4 - Add private, unreleased tool suites

Developers will often want to build onto a Tier 2 or Tier 3 AMI during development
by adding tool suites that have not yet been publicly shared. In general, 
the approach would be to:

- create a new **AWS EC2 _instance_** from the proper Tier 2/3 server AMI
- **server edit suites.yml**, to add a developer tool suite, e.g., 'provider/provider-mdi-tools-dev'
- **server edit server.sh**, to set the server properties and add a <code>GITHUB_PAT</code> with suite access
- **server edit stage2-apps.yml**, to configure the required <code>access_control</code> and, optionally, customize the site
- **server build**, to set the GITHUB_PAT into the image
- **server install**, to install the new tool suite(s)

These are the same basic steps required to launch any server instance from an AMI,
with the additional requirements of specifying the private suite and a GitHub PAT 
with permission to access it.

Typically, such an instance need not be saved as an AMI. In fact, doing so 
is undesirable as the GitHub PAT entered above would be saved with the image.
Instead, once the development tools are ready for release they are copied 
into a public tool suite repository and shared via an updated Tier 3 provider AMI. 

A development suite, e.g., 'provider-mdi-tools-dev', can easily
"piggy back" onto a publicly released tool suite from the same provider, e.g., 
'provider-mdi-tools' by making use of cross-suite referencing of shared code.
This approach allows you to develop integrated code
while keeping some of it private until ready for public release.

```yml
# pipeline.yml
actions:
    actionName:
        condaFamilies:
            - <suite>//shared-conda  
        module: <suite>//example/shared-module
        optionFamilies:
            - <suite>//shared-options
```
