# Michigan Data Interface

The [Michigan Data Interface](https://midataint.github.io/) (MDI) 
is a framework for developing, installing and running a variety of 
HPC data analysis pipelines and interactive R Shiny data visualization 
applications within a standardized design and implementation interface.

## Repository contents

Data analysis in the MDI is logically separated into 
[two stages of code execution](https://midataint.github.io/docs/analysis-flow/) 
called Stage 1 HPC **pipelines** and Stage 2 web applications (i.e., **apps**).
Collectively, pipelines and apps are referred to as **tools**.

This repository carries a single **installation script** that will 
set up the MDI on your computer with all required components and a proper
folder structure to support all available tools.

Please read the [MDI documentation](https://midataint.github.io/) for 
more information.

## System requirements

The script in this repository offers two installation modes, with 
differing requirements.

### Stage 1 Pipelines - Git dependency only

Some users might only run Stage 1 pipelines on an HPC server.
Selecting this installation mode will skip Stage 2 apps 
and directly clone the required MDI repositories. Accordingly, Git must 
be installed on the host machine. See:

- <https://git-scm.com/>

### Stage 2 Pipelines plus Stage 2 Apps - additional R dependency

Stage 2 web apps are R Shiny programs. Accordingly, 
R must be installed on the host machine to use them. See:

- <https://www.r-project.org/>

We recommend updating to the latest stable R release prior
to installing the MDI, as MDI installations are tied to specific 
releases of R (hint: you can install multiple R versions on your 
computer).

Even if R will be used to complete the MDI installation, Git is still
required to download this installer repository to your computer.

### Running on Windows - Git Bash

The MDI installation utility is a bash script. To use it on Windows, 
please install and use Git Bash to expose an appropriate terminal.

- <https://gitforwindows.org/>

Even better, bypass the utility in this repository 
entirely by creating and downloading a customized installation script here:

- <https://wilsonte-umich.shinyapps.io/mdi-script-generator>

## Install the MDI framework(s)

To clone this repository and run the MDI installation script, execute
the following from a command shell.

```bash
git clone https://github.com/MiDataInt/mdi.git
cd mdi
./install.sh
```

Please read the menu options and confirm your installation choice.
A full installation, including Stage 2 apps, will take many minutes 
to complete.

## Configure and install tool suites

<code>install.sh</code> clones MDI repositories
that define the pipeline and apps frameworks, but few actual
tools. To install tools from any provider, run the following from the
command line:

```bash
mdi add https://github.com/GIT_USER/SUITE_NAME-mdi-tools.git
mdi add GIT_USER/SUITE_NAME-mdi-tools # either format works
```

Alternatively, you can edit suites.yml and install new suites
from within the Stage 2 web server.

## Run a Stage 1 pipeline from the command line

The installation process above added the 'mdi' utility
to your MDI installation folder. You can use it to run
any pipeline. For help from the command line, simply call and work from there:

```bash
mdi
```

## Run the MDI web server

If desired, run the Stage 2 apps web server as follows:

```bash
mdi run --help
mdi run
```

In a few seconds a web browser will open and you will be ready to 
load your data and run an associated app.
