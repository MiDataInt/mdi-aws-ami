---
title: Tier 2 AMIs
parent: Building AMIs
has_children: false
nav_order: 20
---

## {{page.title}} - empty AMIs with pre-built Docker images

A Tier 2 empty AMI is defined by its R version. It is created
infrequently to serve as the building block for Tier 3 AMIs carrying tool suites.

## Summary of the empty MDI AMI:

- **source AMI** = appropriate Tier 1 base AMI, from above
- **instance type** = t3.xlarge (4 vCPU, 16 GB RAM)
- **storage** = 20 GB EBS SSD
- **Docker images** = pre-built using 'server build'
- **MDI** = installed into Docker volume as frameworks only (no tool suites):
    - <https://github.com/MiDataInt/mdi-manager.git>
    - <https://github.com/MiDataInt/mdi-pipelines-framework.git>
    - <https://github.com/MiDataInt/mdi-apps-framework.git>

### Storage

Because R creates a large Docker image size, the EBS volume size
is increased for Tier 2 image construction.

### Docker volumes

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
## TIER 2 INSTRUCTIONS - build and install the MDI

We only need to create an empty AMI once per R version, since the
Docker images use a specific R version. The AMI image does not need to be 
recreated to account for MDI updates as these are always available by 
re-pulling the appropriate repositories. Accordingly, the steps below are 
usually only performed by MDI Project administrators. They build the required 
Docker images and use a temporary apps-server container to install the MDI framework
and R packages onto the appropriate Docker volume.

### Launch an AWS instance

Launch an EC2 instance with the specifications listed above. Remember, this new
instance must be in the same region as the AMI itself.

- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

### Log in to the new instance using an SSH terminal

Please see details above.

### Install any pending Ubuntu library upgrades and security patches

```bash
server upgrade
```

### Specify the R version to use for this build

From within a terminal, i.e., bash command shell, on the new instance:

```
server edit server.sh
```

Change the 'R_VERSION' line as needed, and nothing else.

### Build the Docker images

```bash
server build
```

### Install the empty MDI

```bash
server install
```

It takes a while to fully complete the build and 
install sequence, but it doesn't have to be repeated very often.
Any future build will go much faster.

### Secure the empty AMI for public distribution

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

### Save the empty AMI

From within the [AWS Management Console](https://aws.amazon.com/console/), 
select the running EC2 instance and execute:

Actions --> Images and templates --> Create image

The empty image should be named and described according to the following conventions. 

>**name**  
>mdi-empty_ubuntu-22.04_R-4.2.0_yyyy-mm-dd
>
>**description**  
>Michigan Data Interface, empty server image, Ubuntu 22.04, R 4.2.0, yyyy-mm-dd

### Make the AMI public for anyone to use

In the AWS EC2 console, open the AMIs tab, select the AMI you just created and execute:

Actions --> Edit AMI permissions

Choose "Public" and "Save Changes.
