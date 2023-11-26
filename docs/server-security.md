---
title: Server Security
has_children: false
nav_order: 20
---

## {{ page.title }}

As with any public web server, you want to keep security
foremost in your mind from the outset. Many essential security
features are established by editing `config/stage2-apps.yml` as described in detail here:
- <https://midataint.github.io/mdi-apps-framework/docs/server-deployment/server-security.html>

This is what a secure server looks like, including:
- a dedicated domain name
- SSL/TLS encryption, verified by the lock icon in the address bar
- OAuth2 user authentication, in this example via Globus

{% include figure.html file="oauth2.png" %}

### User authentication

The [MDI apps framework](https://midataint.github.io/mdi-apps-framework) that actually serves the MDI web page
has full support for secure server access with authentication
with external authentication services, e.g., 
[Google](https://developers.google.com/identity/protocols/oauth2)
or 
[Globus](https://docs.globus.org/api/auth/).
To use these features, you must have an established developer account
with one of these services.

If you prefer a simpler method, the apps framework
also offers key-based authentication for more moderate security. 

### Encrypted data transfer

MDI web servers further support SSL/TLS encryption security via 
[Let's Encrypt](https://letsencrypt.org/), which is set up
for you by simply entering your domain name in the appropriate config files.

### Server domain names

Both external authentication services and SSL/TLS encryption
require that your server have a permanent domain name mapped to it 
via DNS, so that it can be recognized on the internet. 

A domain name is easily obtained for minimal cost using 
[AWS Route 53](https://aws.amazon.com/route53/).

### Controlling server access via firewalls/security groups

You must also control internet access to your server, which is best
done by IP firewalls that restrict who can make requests to it.
This is achieved in AWS using Security Groups, as decribed here:
- <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html>

Typically, you will keep `http://` (port 80) and `https://` (port 443) ports fully open to the public,
which is fine since you establish secure, authenticated web connections. However, it
is strongly recommended to keep other ports closed, exposing SSH (port 22)
only to the specific IP address of the computer of the person administering the server.

### Maintaining your server via upgrades

Finally, it is important that you keep your server up to date
by applying patches to recently discovered security vulnerabilities.
The `mdi-web-server` code makes this easy by providing a simple
`server upgrade` command via the 
[server managment utility](https://midataint.github.io/mdi-aws-ami/docs/launch-a-server.html#use-the-command-line-utility-to-manage-your-server).
