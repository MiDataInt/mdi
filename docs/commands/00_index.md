---
title: "Command Structure"
has_children: true
nav_order: 20
---

## One utility, multiple actions

Similar to other common utilities (git, docker, etc.), the MDI
utility has various argument formats to execute many needed tasks. 

Call the utility without any subcommands or options to see the basic structures.

```bash
$ mdi

>>> Michigan Data Interface (MDI) <<<

mdi is a utility for:
  - submitting, monitoring and managing Stage 1 data analysis pipelines
  - launching the web interface that runs all Stage 2 interactive apps

usage:
  mdi <pipeline> <data.yml> [options]  # run all pipeline actions in data.yml
  mdi <pipeline> <action> <data.yml> [options] # run one action from data.yml
  mdi <pipeline> <action> <options>    # run one action, all options from command line
  mdi <data.yml> <command> [options]   # apply manager command to one data.yml
  mdi <command> [options] <data.yml ...> [options] # apply manager command to data.yml(s)
  mdi <command> [options]              # additional manager command shortcuts
  mdi <pipeline> <action> --help       # pipeline action help
  mdi <pipeline> --help                # summarize pipeline actions
  mdi <command> --help                 # manager command help
  mdi --help                           # summarize manager commands

<output truncated>
```

### Subcommands

The 'mdi' command often calls a nested program or subcommand, 
denoted as `<command>` above.

### Job configuration files

Many commands act on Stage 1 Pipeline job configurations, 
YAML-format files that specify the work to be done. We refer to this 
as `<data.yml>` above - your file would have its own name.

### Pipeline targets

Many commands execute a specific Stage 1 Pipeline, denoted as `<pipeline>` above.
Other times, the pipeline is specified in the job configuration file.

### Option levels

When setting options, order matters! An option applies to the command word
it follows. You may ultimately wish to set options on the mdi command itself,
on a subcommand, or to override the job configuration file.
