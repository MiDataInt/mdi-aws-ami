---
title: Server Security
has_children: false
nav_order: 20
---

## {{ page.title }}

As with any public web server, you will want to keep security
foremost in your mind from the outset.

## User authentication

The [MDI apps framework](https://midataint.github.io/mdi-apps-framework) that actually serves the MDI web page
has full support for secure server access with authentication
with external authentication services, e.g., Google or Globus.
To use these features, you must have an established developer account
with one of these services.

If you prefer a simpler method, the apps framework
also offers key-based authentication for more moderate security. 

## Encrypted data transfer

MDI web servers further support SSL/TLS encryption security via 
[Let's Encrypt](https://letsencrypt.org/), which is set up
for you by simply entering your domain name in the appropriate config files.

## Server domain names

Both external authentication services and SSL/TLS encryption
require that your server have a permanent domain name mapped to it 
via DNS, so that it can be recognized on the internet. 

A domain name is easily obtained for minimal cost using 
[AWS Route 53](https://console.aws.amazon.com/route53/v2/home).

## Maintaining your server via upgrades

Finally, it is important that you keep your server up-to-date
by applying patches to recently discovered security vulnerabilities.
The `mdi-web-server` code makes this easy by providing a simple
`server upgrade` command via the server managment utility.
