---
title: Tier 3 AMIs
parent: Building AMIs
has_children: false
nav_order: 30
---

## {{page.title}} - add publicly released MDI tool suites

Developers providing tools for others to use
should create a 3rd sequential AMI tier working from the appropriate empty image.
The details of such an image will depend on the needs of the developer,
but the following general steps will typically be needed:

- **server upgrade**, to install any pending system library updates and security patches
- **server edit suites.yml**, to specify tools suites to add to the image
- **server install**, to install those new tools suites

Additionally, some tool providers may wish to include data resources in their image,
which might be installed by actions such as:

- create/clone scripts into **/srv/mdi/resource-scripts** that will install common resources
- **server resource ...**, to download/create the resources

### Secure the provider AMI for public distribution

Most often, provider AMIs should be made public for easy access by all users.
Accordingly, please follow the instructions above for Tier 2 AMIs to
secure your provider AMI for public release by running the following script.

```bash
bash ~/mdi-aws-ami/prepare-public-ami.sh
```

### Save the provider AMI

Provider-specific images should be named and described according to the following conventions. 

>**name**  
>mdi-\<provider\>_ubuntu-22.04_R-4.2.0_yyyy-mm-dd
>
>**description**  
>Michigan Data Interface, \<provider\> server image, Ubuntu Linux 22.04, R 4.2.0, yyyy-mm-dd

### Make the AMI public for anyone to use

In the AWS EC2 console, open the AMIs tab, select the AMI you just created and execute:

Actions --> Edit AMI permissions

Choose "Public" and "Save Changes.
