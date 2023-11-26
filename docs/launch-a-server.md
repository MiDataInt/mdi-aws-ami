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
using a pre-built Tier 2 or Tier 3 AMI, which is much faster, more efficient,
and less confusing for beginners. Choose a Tier 2 AMI if you need to list the tool suites yourself,
or a Tier 3 AMI if one was provided to you by a tool suite developer.

Here is the link to the MDI public AMIs where you will find a suitable Tier 2 AMI (you need to log in to 
AWS for this link to work as expected):
- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;v=3;search=:Michigan%20Data%20Interface>

Once you have found the AMI, simply launch an instance from it.  Adjust the instance size and capacity as suits 
your needs, with the following guidance:
- t3.small instances are acceptable for limited use servers
- t3.medium instances are best for routine use among a small research team
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
$ cd /srv
$ ls -l

total 12
drwxrwxr-x 2 ubuntu mdi-edit 4096 Nov 21 18:12 data
drwxrwxr-x 6 ubuntu mdi-edit 4096 Nov 24 13:17 mdi
drwxr-xr-x 3 root   root     4096 Nov 23 17:44 mnt
```

Folder `mdi` carries the `mdi-web-server` installation,
folders `data` and `mnt` are where you will upload MDI data packages 
and other required data resources.
