---
title: install
parent: Command_Structure
has_children: false
nav_order: 10
---

Here is the rest of the inline help from the 'mdi' command - as you can see, the mdi subcommands apply to various activities that will be of interest to you:

```bash
$ mdi

<continued>

available commands:

  job submission:
    mkdir       create the output directory(s) needed by a job configuration file
    submit      queue all required data analysis jobs on the HPC server
    extend      queue only new or deleted/unsatisfied jobs

  status and result reporting:
    status      show the updated status of all previously queued jobs
    report      show the log file of a previously queued job
    script      show the parsed target script for a previously queued job
    ssh         open a shell, or execute a command, on the host running a job
    top         run the 'top' system monitor on the host running a job
    ls          list the contents of the output directory of a specific job

  error handling:
    delete      kill job(s) that have not yet finished running

  pipeline management:
    rollback    revert the job history to a previously archived status file
    purge       clear all status, script and log files associated with the job set

  server management:
    initialize  refresh the 'mdi' script to establish its program targets
    install     re-run the installation process to update suites, etc.
    alias       create an alias, i.e., named shortcut, to this MDI program target
    add         add one tool suite repository to config/suites.yml and re-install
    list        list all pipelines and apps available in this MDI installation
    unlock      remove all framework and suite repository locks, to reset after error
    build       build one container with all of a suite's pipelines and apps
    server      launch the web server to use interactive Stage 2 apps
```


## Installation (server) management

Once it is installed the first time, the mdi utility has functions
to help update and maintain the installation.

## Pipeline execution and monitoring

It is possible to use the mdi utility to execute installed pipelines 
synchronously in the command shell, e.g.:

```bash
mdi myPipeline do myData.yml --my-option 22

<executes 'myPipeline do' on myData.yml, overriding option '--my-option'>
```

However, the nature of HPC pipelines means you will probably
want to use the utility to submit work to your cluster server's job scheduler, e.g.:

```bash
mdi submit myData.yml --my-option 22

<similar to above, but defers execution to a server node>
```

## Help on subcommands

Subcommands offer their own inline help when called with no options. 
We won't repeat them all, but as one example:

```bash
$ mdi submit

mdi submit: queue all required data analysis jobs on the HPC server

available options:
  -d,--dry-run        check syntax and report actions to be taken; nothing will be queued or deleted
  -x,--delete         kill matching pending/running jobs when repeat job submissions are encountered
  -e,--execute        run target jobs immediately in the shell instead of scheduling them
  -f,--force          suppress warnings that duplicate jobs will be queued, files deleted, etc.
```