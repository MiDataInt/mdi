---
title: Job Config Files
has_children: false
nav_order: 40
---

## {{ page.title }}

MDI pipeline executions are controlled by a job configuration file,
i.e., a 'data.yml' file.  This versatile YAML-format script makes it easy
to construct complex work sequences, including parallel array jobs and 
serial actions.

Other advantages of job configuration files are that you have better control
over many options and a ready means of tracking your work,
including by examining associated job output logs.

### YAML format

Job config files are valid YAML files, although the interpreter
we use to read them only processes a subset of YAML features.
[Learn more about YAML on the internet](https://www.google.com/search?q=yaml+basics), 
or just proceed, it is intuitive and easy.

### Config file templates

To get a template to help you quickly write a new job configuration:

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
        option_1: 99 # a single keyed option value
pipelineAction:
    optionFamily_1:
        option_1: ${VAR_NAME} # a value from a variable
anotherAction:
    optionFamily_2:
        option_2:
            - valueA # an array of option values, executed in parallel
            - valueB      
execute:
    - pipelineAction # pipelineAction overrides shared option_1
    - anotherAction  # anotherAction has access to option_1 and option_2
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

The 'variables' section
allows you to assign values to variables that can be recalled further down
in standard shell syntax. The reason to use variables is to prevent
typing the same thing over and over!

### Option sharing between actions

Another means of streamlining config files exploits the fact that different
actions in a pipeline often use the same options.  By specifying them in the
'shared' section, you only have to enter them once. Any values listed
under an action key will take precedence.

### Environment config files

As a further convenience, when you get tired of having many files
with the same option values (e.g., a shared directory) you may
also create a file called 'pipeline.yml' or '\<pipelineName\>.yml'
in the same directory as '\<data\>.yml'. 

Options will be read
from 'pipeline.yml' first, then '\<data\>.yml', then finally
from any values you specify on the command line, with the last 
value that is read taking precedence, i.e., options specified on the 
command line have the highest precedence.

### Option recycling - parallel array jobs

A key feature of option values in job files is that they "recycle" as in
vectorized programming.  If all options have a single value,
a single job will result. However, if one or more options have multiple
assigned values, all single-value options are reused along with
each of the list option values. 

Thus, the following example:

```yml
actionName:
    optionFamily:
        option_1: AAA
        option_2: 1 2 # whitespace-separated values are interpreted as lists ...
        option_3: 
            - 3 # ... as is the standard YAML list syntax
            - 4
```  

would result in an array job with two tasks, as follows:

| Array Task # | option_1 | option_2 | option_3 |
| ------------ | -------- | -------- | -------- |
| 1            | AAA      | 1        | 3        |
| 2            | AAA      | 2        | 4        |



Importantly, if one option has multiple values, every other option must either
have the same number of values or a single value. You will get an error message
if you have option lists of different lengths.

### Options repeated in log files

When you examine job log files with 'mdi report' you will find that
all job options are repeated back to you in YAML format, for an
unambiguous, permanent record of what was done. You can turn this feature
off with option '--quiet'.

### Multi-pipeline job files

When you are ready to increase the complexity of your job sequences still
further, config files support the use of YAML blocks to make sequential
calls to multiple pipelines in the same data.yml file. 

```yml
# data.yml
---
variables: # declarations here are available to both pipelines below
shared:
--- # '---' is the text sequence that starts a new YAML block
pipeline: pipeline_1
actionX:
execute:
    - actionX
---
pipeline: pipeline_2
actionY:
execute:
    - actionY
```

The net effect is like executing the same mdi subcommand on two
different data.yml files, except that now the declarations in 
'variables' and 'shared' are available to both pipelines.

Using this approach, you can can perform initial processing
tasks with a first pipeline and continue with further processing
with a second (or third...) pipeline, all with the convenience 
of shared variables and mdi commands.

