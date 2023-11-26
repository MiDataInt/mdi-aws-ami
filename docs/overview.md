---
title: "MDI Web Servers"
has_children: false
nav_order: 0
---

{% include mdi-project-overview.md %} 

The MDI offers code and pre-built machine images (AMIs) for quickly launching Stage 2 Apps 
in a public-facing web server hosted on 
[Amazon Web Services](https://aws.amazon.com/) (AWS). 
There are two relevant MDI repositories:
- [mdi-aws-ami](https://github.com/MiDataInt/mdi-aws-ami/), which carries code used to build the AMIs
- [mdi-web-server](https://github.com/MiDataInt/mdi-web-server/), which carries code placed into the AMIs to manage and launch the web server

The details of these two repositories are mostly for MDI project developers,
although some advanced users may wish to build their own images or servers.

Most end users will simply wish to use the pre-built tools 
to launch their own MDI web server.

{% include mdi-project-documentation.md %}
