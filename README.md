# mdi-aws-ami

Admin-only resources to create Amazon Machine Images (AMIs) for launching 
MDI public servers on Amazon Web Services (AWS).

Information on AWS AMIs can be found here:  
<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html>

## Sequential AMI plan

AMIs backed by EBS volumes are stored as snapshots that build on each other, 
i.e., later AMIs only store the _changes_ relative to earlier AMIs.
Therefore, we build MDI AMIs sequentially to allow streamlined creation
of additional later AMIs, e.g., for a newly released R version.

## STEP 1 - Base AMI with Linux OS and cloned MDI Server Repo

### Summary of base AMI details:

- **base AMI** = Ubuntu 20.04 standard image, X86_64
- **Linux user** = ubuntu, the AWS standard
- **region** = Ohio, us-east-2
- **instance type** = t3.medium (2 vCPU, 4 GB RAM)
- **storage** = ?? GB EBS SSD

#### Linux operating system

The MDI can run on any operating system, but the MDI uses Ubuntu Linux
by default, with version 20.04 being current as of this writing.

#### AWS region

AWS AMIs are region specific, i.e., they are only available to be used
for launching instances in the same region as the AMI itself. Because
the MDI uses a "Michigan first" approach, we build all AMIs in the
Ohio, us-east-2 AWS region.

#### Instance type

An AMI is not tied to a specific instance type, but we create the 
AMIs with the same resources as is recommended for eventual running
instances, i.e., t3 medium.

#### Storage

??

### Step 1a - create the base image instance

We only need to create a base image once per Ubuntu version. The base
steps will clone this repo and execute the server configuration script
to prepare the server for installing the MDI in later steps/AMIs.

#### Launch instance

Launch an EC2 instance with the parameter details specified above.

#### Update the OS

```
apt-get update
apt-get upgrade -y
```

#### Install Git

```
apt-get install -y git
```

#### Clone this repository

```
cd ~
git clone https://github.com/MiDataInt/mdi-aws-ami.git
```



- 











