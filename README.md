# MDI Command Line Installer and Utility

The [Michigan Data Interface](https://midataint.github.io/) (MDI) 
is a framework for developing, installing and running 
Stage 1 HPC **pipelines** and Stage 2 interactive web applications 
(i.e., **apps**) in a standardized design interface.

This repository carries an **installation script** that will 
set up the MDI on your Linux server with all required components and 
a proper folder structure to support all tools.

## System requirements

The MDI offers two installation levels, with differing system requirements.

### Stage 1 Pipelines - Git dependency only

Some users might only run Stage 1 pipelines on an HPC server.
This installation level skips Stage 2 apps 
and directly clones the required MDI repositories. 
Accordingly, Git must be installed.

- Git: <https://git-scm.com/>

### Stage 2 Pipelines plus Stage 2 Apps - additional R dependency

Stage 2 web apps are R Shiny programs. Therefore, R must be installed.
Git is still required to download this installer repository.

- R: <https://www.r-project.org/>

### Running Stage 2 Apps on your desktop or laptop

The Stage 2 web server runs perfectly well on Windows or Mac computers,
but this installation script will not be useful. Instead,
install either the MDI Desktop or the R 'mdi-manager' package:

- MDI Desktop (recommended): <https://midataint.github.io/mdi-desktop-app>
- MDI R package: <https://midataint.github.io/mdi-manager>

In remote modes, the recommended MDI Desktop will install
and makes calls to the MDI command line utility for you, via SSH. 

## Install the MDI framework(s)

To clone this repository and run the MDI installation script, execute
the following from a command shell.

```bash
git clone https://github.com/MiDataInt/mdi.git
cd mdi
./install.sh
```

Please read the menu options and confirm your installation choice.
A full installation including Stage 2 apps will take many minutes 
to complete.

## OPTIONAL: Create an alias to the 'mdi' utility

The following commands will create an alias to the main 'mdi' utility
in your new MDI installation for easy access.

```bash
# from within the mdi directory
./mdi alias --alias mdi # change the alias name if you'd like
`./mdi alias --alias mdi --get` # activate the alias in the current shell (or log back in)
```

You could also edit your shell files to modify the PATH variable.

## Configure and install tool suites

<code>install.sh</code> clones MDI repositories
that define the pipeline and apps frameworks, but few actual
tools. To install tools from any provider, first edit file 
'config/suites.yml' in the 'mdi' root directory.

```yml
# mdi/config/suites.yml
suites:
    - GIT_USER/SUITE_NAME-mdi-tools # either format works
    - https://github.com/GIT_USER/SUITE_NAME-mdi-tools.git
```

Then call <code>install.sh</code> again to clone the listed
repositories and install any additional R package dependencies.
Repeat these steps to add additional tool suites to your MDI installation.

Alternatively, you can edit suites.yml and install new suites from within 
the Stage 2 web server, or run the following from the command line:

```bash
mdi add --help
mdi add -s GIT_USER/SUITE_NAME-mdi-tools # either format works
mdi add -s https://github.com/GIT_USER/SUITE_NAME-mdi-tools.git
```

## Run a Stage 1 pipeline from the command line

The installation process adds the 'mdi' utility
to your MDI installation folder. You can use it to run
any pipeline. For help from the command line, simply call
the utility with no arguments:

```bash
./mdi
mdi # if you created an alias above
```

## Run the MDI web server

While you can launch the MDI web server using the command line utility,
it is much better to use the [MDI Desktop app](https://midataint.github.io/mdi-desktop-app),
which allows you to control both local and remote MDI web servers.

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
creating file '~/gitCredentials.R' or 'mdi/gitCredentials.R':

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
./mdi install --help
./mdi install --forks # Stage 1 pipelines only
./mdi install --forks --install-packages # Stage 1 and Stage 2
```

Finally, add the '--develop/-d' flag to your 'mdi' calls, which will
use any forked repositories from your GitHub account, or, if you have no forks,
the tip of the main branch of the definitive repository (instead of a versioned release commit).

```bash
mdi -d ...
mdi --develop ...
```
