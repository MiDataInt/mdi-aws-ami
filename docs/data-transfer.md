---
title: Data Transfer
has_children: false
nav_order: 60
---

## {{ page.title }}

For it to be useful, you must of course get your data onto your web server.

### Make sure your data are suitable for upload

Before proceeding, think hard about data privacy and what you
can and cannot safely store on an AWS file system.
For example, you may be subject to restrictions on certain 
human data types. It is up to you to adhere to any applicable regulations.

As you deliberate, remember you probably don't need to upload
all your data to the web server. As below, web apps often only need
final processed data files that might not contain any restricted data, 
depending on your pipeline.

If you cannot use an AWS server, you can still run MDI web apps on your
own secure server. Use the 
[MDI Desktop App](https://midataint.github.io/mdi-desktop-app/docs/overview)
to access your server and run the app there over a secure SSH tunnel.
That method is almost certainly compatible with any access restrictions
while fully supporting all MDI app functionality.

### Have your pipelines create data packages (for pipeline developers)

Of course, you can use any familiar method you'd like to copy files
onto your server, e.g., drag and drop into VS Code works great.
You may need that for general purpose resource files not linked to specific data or experiments.

However, the
[MDI analysis work flow](https://midataint.github.io/docs/analysis-flow/)
is designed to help you connect the outputs of your intensive Stage 1 HPC
data analysis pipelines to your Stage 2 interactive apps. The idea
is that your pipelines will produce smaller, processed data files that can be easily
and automatically pushed to an apps server when your pipeline job ends.

Specifically, your pipelines should assemble 'data packages', which
are single zipped files carrying a series of standard and pipeline-specific data 
and metadata files. Instructions for specifying data package assembly are provided here:
- <https://midataint.github.io/mdi-suite-template/docs/pipelines/pipeline_yml.html#data-package-declaration>

### Use the 'push' function of pipeline job files (for end users)

All MDI pipelines implicitly support `push` options you can use to execute
the transfer of pipeline data packages to your server.  Simply declare values
for the following options for the pipeline action that creates the data package, e.g.,:

```sh
$ mdi svWGS find

--- snip ---
push:
  --push-server       <string> external server domain name, e.g, on AWS, to which data packages should be pushed with scp [null]
  --push-dir          <string> directory on --push-server to which data packages will be pushed [/srv/data]
  --push-user         <string> valid user name on --push-server, authorized by --push-key [ubuntu]
  --push-key          <string> path to an ssh key file for which --push-user has a public key on --push-server [~/.ssh/mdi-push-key.pem]
--- snip ---
```

```sh
$ mdi svWGS template -a

--- snip ---
find:
    push:
        push-server:    null
        push-dir:       /srv/data
        push-user:      ubuntu
        push-key:       ~/.ssh/mdi-push-key.pem
--- snip ---
```

Briefly, `push-server/push-directory` 
is where the data package will be placed after copying, while `push-user`
and `push-key` authorize you to access the server. As with all SSH key files, `push-key` must have user-only permissions, e.g.:

```sh
chmod go-rwx ~/.ssh/mdi-push-key.pem
```

#### Troubleshooting #1 - HPC server outgoing SSH

There are two important networking requirements for data push to
work correctly.

First, the HPC server where your job runs must allow outbound SSH connections.
This may not be true on a cluster node where your job runs. That information
will be reported to you in the job's log report, i.e.:

```sh
mdi report myJobFile.yml
```

In that case,
simply repeat the pipeline call to the same job file in interactive mode after the run ends, e.g.:

```sh
mdi svWGS find myJobFile.yml
```

Don't worry, for a well designed pipeline this won't re-launch all the work.
The pipeline will skip over prior successful actions and simply run the data
push it couldn't do on the worker node.

#### Troubleshooting #2 - AWS security group incoming SSH

In addition, your AWS server must be willing to accept incoming SSH connections
from the IP address of your HPC server. Adjust these settings in your 
AWS Security Group, as decribed here:
- <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html>

As always, be as restrictive as possible with the SSH ports
you open on your server - try to allow only the IP of your HPC server,
or at most a CIDR group restricted to your institution's IP pool.
