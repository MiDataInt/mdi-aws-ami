# MDI AWS AMI Support

The [Michigan Data Interface](https://midataint.github.io/) (MDI) 
is a framework for developing, installing and running 
Stage 1 HPC **pipelines** and Stage 2 interactive web applications 
(i.e., **apps**) in a standardized design interface.

The MDI offers code and pre-built machine images (AMIs) for quickly launching Stage 2 Apps 
in a public-facing web server hosted on 
[Amazon Web Services](https://aws.amazon.com/) (AWS). 
There are two relevant MDI repositories:
- [mdi-aws-ami](https://github.com/MiDataInt/mdi-aws-ami/), which carries code used to build the AMIs
- [mdi-web-server](https://github.com/MiDataInt/mdi-web-server/), which carries code placed into the AMIs to manage and launch the web server

This is the former repository for the **MDI AMI installers**. 
It is mostly relevant to MDI project administrators.

Detailed instructions covering both the `mdi-aws-ami` and `mdi-web-server` repositories
can be found here:

- <https://midataint.github.io/mdi-aws-ami>

You will also need to be familiar with the `mdi-apps-framework`,
which carries the R code that runs the web page itself.

- <https://midataint.github.io/mdi-apps-framework>
