---
title: Editing Server R Code
has_children: false
nav_order: 75
---

## {{ page.title }}

Developers may find it convenient to edit code in a MDI web server running on a public AWS instance to develop its codebase. It requires just two additional steps in VS Code to connect into the Docker container where your web server runs. 

### 1 - Install VS Code and the required remote and container extensions

Install and open VS Code on your local computer, i.e., your desktop or laptop.

Install the **Remote – SSH** extension in VS Code.

Install **Dev Containers** extension in VS Code.

You probably did the first two installations previously, but needed to install Dev Containers, which provides support for editing code inside a running container.

### 2 - Create a developer MDI web server instance

Follow instructions in the previous tabs to create, connect to, build and install an AWS instance hosting an MDI web server. 

.This will typically be a second developer instance of your web server, e.g., `dev.my-mdi.io`, assuming you already have a production instance in use at `my-mdi.io`. That way you can develop new code without interfering with production use.

### 3 – Launch your AWS web server in developer mode

(Re-)Connect to your AWS web server using VS Code Remote – SSH, then start the web server in developer mode by executing:

```sh
server up dev
```

Adding the `dev` option to the standard `server up` sub-command launches the web server in interactive mode (so you can see the log output from the server) and places all repositories at the tip of the main branch (not at the latest release tag). 

It also preferentially uses cloned developer forks of all framework and suite repositories if environment variable GIT_USER was set in config file `server.sh`. Otherwise, you will be editing at the tip of the main branch in the definitive repository. 

### 4 – Direct VS Code to run inside your apps-server container

Hit `F1` from within VS Code and run **Dev Containers: Attach to Running Container**. 

Select the container named `mdi-web-server-app-server`. This is the Docker container with cloned versions of the MDI apps repos that is running your web page. If you aren’t offered any containers to attach to, you most likely forgot to launch the server using `server up dev`.

The first time you do this it will take a minute or two to install the VS Code Server into the new container. Next connections will go faster.

### 5 – Edit and push code as per normal

Open Folder `/srv` and use the VS Code file browser to navigate to your suite’s code and any other files you’d like to open and/or edit, e.g., editing files in path `/srv/mdi/suites/developer-forks/<suite>/shiny`. Reload the web page as needed to monitor the effects of your code changes (or use the more limited code refresh icon at the top).

When done, open a terminal window into your repository folder and use `git add`, `git commit` and `git push` as you normally would.
