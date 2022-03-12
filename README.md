# Michigan Data Interface

The [Michigan Data Interface](https://midataint.github.io/) (MDI) 
is a framework for developing, installing and running a variety of 
HPC data analysis pipelines and interactive R Shiny data visualization 
applications within a standardized design and implementation interface.

Data analysis in the MDI is separated into 
[two stages of code execution](https://midataint.github.io/docs/analysis-flow/) 
called Stage 1 HPC **pipelines** and Stage 2 web applications (i.e., **apps**).
Collectively, pipelines and apps are referred to as **tools**.

## Repository contents

This repository carries a single **installation script** that will 
set up the MDI on your computer with all required components and a proper
folder structure to support all tools.

## System requirements

The MDI offers two installation levels, with differing system requirements.

### Stage 1 Pipelines - Git dependency only

Some users might only run Stage 1 pipelines on an HPC server.
This installation level skips Stage 2 apps 
and directly clones the required MDI repositories. Accordingly, Git must 
be installed on the host machine.

- Git: <https://git-scm.com/>

### Stage 2 Pipelines plus Stage 2 Apps - additional R / Singularity dependency

Stage 2 web apps are R Shiny programs. R might run on the host machine
directly, or within a Singularity container. Therefore, either R or
Singularity (but not both) must be installed.
Git is still required to download this installer repository.

- R: <https://www.r-project.org/>
- Singularity: <https://sylabs.io/>

### Running Stage 2 Apps on your desktop or laptop

The Stage 2 web server runs perfectly well on Windows or Mac computers,
but this installation script will not be useful. Instead,
either install the MDI using the R 'mdi-manager' package, or download a customized batch script to install and run the server:

- MDI manager: <https://github.com/MiDataInt/mdi-manager.git>
- batch script generator: <https://wilsonte-umich.shinyapps.io/mdi-script-generator>

## Install the MDI framework(s)

To clone this repository and run the MDI installation script, execute
the following from a command shell.

```bash
git clone https://github.com/MiDataInt/mdi.git
cd mdi
./install.sh
```

Please read the menu options and confirm your installation choice.
A full installation, including Stage 2 apps, can take many minutes 
to complete if not using containers.

If you will use containers but need to provide an atypical
command to load Singularity, please initially select installation 
level 1 (pipelines only), then edit file 'config/singularity.yml'
and re-run the installer. 

## OPTIONAL: Create an alias to the 'mdi' utility

The following commands will create an alias to the main 'mdi' utility
in your new MDI installation for easy access.

```bash
# from within the mdi directory
./mdi alias --alias mdi # change the alias name if you'd like
`./mdi alias --alias mdi --get` # activate the alias in the current shell too
```

## Configure and install tool suites

<code>install.sh</code> clones MDI repositories
that define the pipeline and apps frameworks, but few actual
tools. To install tools from any provider, first edit file 
'config/suites.yml' in the 'mdi' root directory.

```yml
# mdi/config/suites.yml
suites:
    - https://github.com/GIT_USER/SUITE_NAME-mdi-tools.git
    - GIT_USER/SUITE_NAME-mdi-tools # either format works
```

Then call <code>install.sh</code> again to clone the listed
repositories and install any additional R package dependencies.
Repeat these steps to add additional tool suites to your MDI installation.

Alternatively, you can edit suites.yml and install new suites from within 
the Stage 2 web server, or run the following from the command line:

```bash
mdi add --help
mdi add -s https://github.com/GIT_USER/SUITE_NAME-mdi-tools.git
mdi add -s GIT_USER/SUITE_NAME-mdi-tools # either format works
```

## Run a Stage 1 pipeline from the command line

The installation process adds the 'mdi' utility
to your MDI installation folder. You can use it to run
any pipeline. For help from the command line, simply call
the utility with no arguments:

```bash
mdi
```

## Run the MDI web server

Run the Stage 2 apps web server as follows - in a few seconds a web browser will open and you will be ready to load your data and run an associated app.

```bash
mdi run --help
mdi run
```

## Install and use repository developer forks

Code developers often maintain forks of MDI framework and tool suite
repositories in their GitHub account. To install your forks alongside the definitive
repositories, first make sure R is installed and loaded:

```bash
# example for UM Great Lakes
module load R/4.1.0
```

Next, provide a 
[GithHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
by setting environment variable GITHUB_PAT or 
creating file '~/gitCredentials.R' or'mdi/gitCredentials.R':

```r
# ~/gitCredentials.R
gitCredentials <- list(
    USER_NAME  = "First Name",
    USER_EMAIL = "namef@umich.edu",
    GIT_USER   = "xxx",
    GITHUB_PAT = "xxx"
)
```

After running <code>install.sh</code> as described above, re-run 
the installation as follows, which calls the <code>mdi::install()</code>
R function capable of installing forked repos.

```bash
./mdi install --forks # Stage 1 pipelines only
./mdi install --forks --install-packages # Stage 1 and Stage 2
```

Finally, add the 'develop' flag to your 'mdi' calls, which will
use any forked repositories from your GitHub account, or, if you have no forks,
the tip of the main branch of the definitive repository (instead of a versioned release commit).

```bash
mdi -d ...
mdi --develop ...
```


