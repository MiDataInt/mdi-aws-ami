---
title: Server Structure
has_children: false
nav_order: 10
---

## {{ page.title }}

MDI public web servers are hosted on AWS EC2 instances constructed from AWS AMIs according the hierarchy below.

Additional information on AWS AMIs and EC2 instances can be found here:  
-  [Amazon Machine Images](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [Elastic Compute Cloud](https://aws.amazon.com/pm/ec2) (EC2) instances

### Tiered AMI/instance construction

To facilitate construction and maintenance, AMIs and associated instances are constructed
in stages, i.e, tiers, as follows:

- **Tier 1 "bare" AMIs** carry a specific Linux operating system and Docker
- **Tier 2 "empty" AMIs** additionally carry a specific R installation and the MDI with no tool suites
- **Tier 3 "tool suite" AMIs/instances** additionally carry installed public tool suites and resources
- **Tier 4 "private" AMIs/instances** additionally carry installed private tool suites and resources

Tiers 1 to 3 are suitable for public sharing, Tier 4 is not. 

Tier 1 and 2 AMIs are prepared by MDI project administrators, whereas Tier 3 and 4 AMIs
are prepared if needed by specific research teams.

Tiers 3 and 4 need not be saved as AMIs, i.e., images, at all if sharing is not important.
They can simply be maintained as working Tier 3 or 4 web server instances. 

Most users will therefore want to start from a Tier 2 empty AMI and add their tool suite(s) 
to create a Tier 3 instance. Briefly here, you will:
- use an MDI Tier 2 AMI to `launch` your AWS EC2 instance
- `edit` a few files to establish server configuration details (e.g., your web domain)
- `build` your final container images
- `install` your tool suite code
- make your site live, i.e., bring it `up`

Each of these actions are encapsulated in the `server` management utility 
provided by `mdi-web-server` code to make server management easy.

### Web server microservices run as Docker containers

MDI web servers run as a set of microservices from within
Docker containers. 

- <https://www.docker.com/>

One container runs the Traefik reverse proxy/load balancer
and routes requests to the other microservices.

- <https://docs.traefik.io/>

Other containers run the MDI, i.e., R Shiny, and other required 
support services. The `mdi-web-server` repository has all files needed to 
build and manage all microservice images.

Your web server instance can be scaled to run one or multiple
R Shiny Docker containers, which can each independently serve
multiple different users to achieve substantial load balancing via Traefik.

> **AWS vs. Docker images**
>
>As a note of caution, the word 'image' is used by both AWS and Docker - do not 
confuse AWS images and Docker images.
>
>AMIs represent the installation of a server OS and 
support programs that can be launched as an EC2
instance. These support programs include Docker, installed in Tier 1 AMIs. 
>
>Docker images represent the installation of a server OS and support programs
that can be launched as a Docker container, running on the EC2 instance that
was created from an AMI. Docker images are built in Tier 2 AMIs, e.g., to
allow a new MDI installation based on a new R version.
>

### Data storage

MDI AWS AMIs are backed by EBS volumes stored as snapshots that build on each other, 
i.e., later AMIs only store the changes relative to earlier AMIs.

You must launch your instance with at least as much storage as the AMI itself,
but can request more storage (or a larger intances) as suits your needs.

However, as your data needs grow, it is highly recommended to create an
[Amazon Elastic File System](https://aws.amazon.com/efs/) (EFS) and mount it to your web server, which
allows you data to be managed separately from the server resources.
MDI web servers are ready for you to mount your EFS to path `/srv/mnt/efs`.
