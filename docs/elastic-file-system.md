---
title: Elastic File System
has_children: false
nav_order: 10
---

## {{ page.title }}

Some apps require access to data files that are too large to put into an MDI data package.
On an AWS public server, a good solution for handling such large files is to mount an AWS 
Elastic File System (EFS) to your MDI server instance.

First, use the instructions from AWS to create your EFS, making note of the file system ID.
- <https://docs.aws.amazon.com/efs/latest/ug/gs-step-two-create-efs-resources.html>

Next, launch and populate a Tier 3 or Tier 4 MDI server instance using our AMIs as described above.

Use the AWS Management Console to ensure that your AWS server instance is a member of the same
VPC security group as your EFS. This security group was created when you created your EFS.

Log into your instance using SSH and run:

```
server edit mount.sh
```

Follow the instructions in the file comments, editing the file path and file system ID
as needed to match your server and EFS. 

Finally, start the server, where the `up` command will automatically mount the EFS and 
bind-mount /srv/mnt into your app-server containers.

```
server up
```

To use the new EFS mount, adjust either your server config or your app to use the appropriate
file paths when finding data files.
