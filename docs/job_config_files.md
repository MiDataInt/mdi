---
title: Job Config Files
has_children: false
nav_order: 40
---

## {{ page.title }}

At the heart of most pipeline executions is a job configuration file,
i.e., a 'data.yml' file.  This versatile YAML-format tool makes it easy
to construct and execute complex pipeline action sequences.

Advantages of job configuration files are that you have better control
over many options and have a ready means of tracking your work,
including by examining associated job output logs.

### YAML format

Job config files are valid YAML files, although the interpreter
we use to read them only processes a subset of YAML features.
[Learn more about YAML on the internet](https://www.google.com/search?q=yaml+basics), 
or just proceed, it is intuitive and easy.

### Config file templates

To get a template to help you write your config file use:

```bash
mdi <pipelineName> template --help
mdi <pipelineName> template
```

### Config file syntax

In general, the job config syntax is:

```yml
# data.yml
---
pipeline: [suiteName/]pipelineName[:suiteVersion]
variables:
    VAR_NAME: value
shared:
    optionFamily_1:
        optionName_1: 99 # a single keyed option value
pipelineAction:
    optionFamily_1:
        optionName_1: ${VAR_NAME} # a value from a variable
anotherAction:
    optionFamily_2:
        optionName_2:
            - valueA # an array of option values, executed in parallel
            - valueB      
execute:
    - pipelineAction # pipelineAction overrides shared optionName_1
    - anotherAction  # has access to optionName_1 and optionName_2
```

### Pipeline target declaration

The 'suiteName' and 'version' components of the pipeline declaration 
are optional, however, including suiteName can improve clarity and ensure that
you are always using the tool you intend. If provided, the version designation should
be either:

- a suite release tag of the form 'v0.0.0'
- 'latest', to use the most recent release tag [the default]
- 'pre-release', to use the development code at the tip of the main branch
- for developers, the name of a code branch in the git repository

### Config file variables

The 'variables' section acts like an initial code block by
allowing you to assign values to variables that can be recalled further down
in standard shell syntax. The reason to use variables is to prevent
typing the same thing over and over!

### Option sharing between actions

Another means of streamlining config files exploits the facts that different
actions in a pipeline often use common options.  By specifying them in the
'shared' section, you only have to enter them once. Any values listed
under the action itself will take precedence.

### Environment config files

As a further convenience when you get tired of have many files
with the same option values (e.g., a shared data directory), you may
also create a file called 'pipeline.yml' or '\<pipelineName\>.yml'
in the same directory as '\<data\>.yml'. 

Options will be read
from 'pipeline.yml' first, then '\<data\>.yml', then finally
from any values you specify on the command line, with the last 
value that is read taking precedence, i.e., options specified on the 
command line have the highest precedence.

### Options repeated in log files

When you examine job log files with 'mdi report' you will find that
all job options are repeated back to you in YAML format, for an
unambiguous, permanent record of what was done. You can turn this feature
off with option '--quiet'.

