---
title: Manage Your Server
has_children: false
nav_order: 35
---

## {{ page.title }}

The `mdi-web-server` repository provides a convenient command line
management utility that will help you perform all required server
tasks without needing deep familiarity with Docker, R
or other server components. Simply type `server` to get started.

```sh
$ server

usage:  ./server <COMMAND> ...

server execution commands (in order of usage):
    upgrade   use apt to install all updated system libraries and security patches
    edit      use nano to edit one of the server configuration files
    build     run docker compose build to create all needed Docker images
    install   update the server config, clone GitHub repos, install R packages
    up        launch all containers to run the MDI apps server
    ls        list all stored Docker images and running containers
    update    copy updated config files into server containers without reinstalling
    down      stop and remove any running containers to shut down the apps server

additional resource management commands:
    resource  run a script to download/install data into the permanent Docker volume
    bash      bring up an interactive bash terminal in a new apps-server container
```

The sub-commands are named informatively and hopefully with the brief 
descriptions it will be apparent what each one does. You may want
to refamiliarize yourself with the 
[web server structure](https://midataint.github.io/mdi-aws-ami/docs/server-structure.html)
if not clear.

Importantly, the `server` subcommands are presented in logical order of their
usage to get your server up and running. Start from the top and work down!

### Server configuration files

The `edit` command will bring up the nano text editor so that you can
edit one of the following required or optional configuration files.

```sh
$ server edit

usage:  ./server edit <CONFIG_FILE>

where CONFIG_FILE is one of:
    server.sh             server configuration metadata
    suites.yml            tool suites to install
    stage2-apps.yml       access control options for the apps server
    mount.sh              optional commands to mount external file systems to /srv/mnt/...
```

Advanced users will probably find it easier to just edit the config files
from within VS Code. They are all found under directory `/srv/mdi/config`.

As with the `server` sub-commands, we will not provide detailed additional
documentation here because each configuration file has detailed comments
to help you fill them in properly. Briefly, you will use the files to:
- describe your server
- establish a secure login approach
- declare the tool suites you wish to use

Also, the trickiest bits regarding server security and file paths
are documented in detail in the `mdi-apps-framework`:

- <https://midataint.github.io/mdi-apps-framework/docs/server-deployment/server-security.html>
- <https://midataint.github.io/mdi-apps-framework/docs/server-deployment/shinyFiles.html>
