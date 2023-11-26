---
title: Tier 4 AMIs
parent: Building AMIs
has_children: false
nav_order: 40
---

## {{page.title}} - add private, unreleased tool suites

Developers will often want to build onto a Tier 2 or Tier 3 AMI during development
by adding tool suites that have not yet been publicly shared. In general, 
the approach would be to:

- create a new **AWS EC2 _instance_** from the proper Tier 2/3 server AMI
- **server upgrade**, to install any pending system library updates and security patches
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
