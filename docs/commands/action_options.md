---
title: "Action Options"
parent: "Command Structure"
has_children: false
nav_order: 30
---

## {{ page.title }}

Each **action** offered by a pipeline will have a rich set of available **options**. 
For example, here is the inline help for the 'svCapture align' action.

```
$ mdi svCapture align

svCapture: Characterize structural variant junctions in short-read, paired-end capture library(s)

align: clean paired-end reads and align to reference genome; output name-sorted bam/cram

fastq-input:
  -i,--input-dir      <string> expects <input-dir>/<input-name>/*.fastq.gz, <input-dir>/<input-name>_*.fastq.gz, or .sra *REQUIRED*
  -I,--input-name     <string> see --input-dir for details; defaults to --data-name if null [null]

<truncated for brevity> 

output:
  -O,--output-dir     <string> the directory where output files will be placed; must already exist *REQUIRED*
  -N,--data-name      <string> simple name for the data (e.g., sample) being analyzed (no spaces or periods) *REQUIRED*

version:
  -v,--version        <string> the version to use of the tool suite that provides the requested pipeline [latest]

resources:
  --account           <string> name of the account used to run a job on the server [NA]
  -m,--runtime        <string> execution environment: one of direct, container, or auto (container if supported) [auto]
  -p,--n-cpu          <integer> number of CPUs used for parallel processing [1]
  -r,--ram-per-cpu    <string> RAM allocated per CPU (e.g., 500M, 4G) [4G]
  -t,--tmp-dir        <string> directory used for small temporary files (recommend SSD) [/tmp]
  -T,--tmp-dir-large  <string> directory used for large temporary files (generally >10GB) [/tmp]

job-manager:
  --email             <string> email address of the user submitting the job [nobody@nowhere.edu]
  --account           <string> name of the account used to run a job on the server [NA]
  --time-limit        <string> time limit for the running job (e.g., dd-hh:mm:ss for slurm --time) [10:00]
  --partition         <string> slurm --partition (standard, gpu, largemem, viz, standard-oc) [standard]

workflow:
  -f,--force          <boolean> execute certain actions and outcomes without prompting (create, rollback, etc.) 
  -R,--rollback       <integer> revert to this pipeline step number before beginning at the next step (implies --force) [null]
  -q,--quiet          <boolean> suppress the configuration feedback in the output log stream 

help:
  -h,--help           <boolean> show pipeline help 
  -d,--dry-run        <boolean> only show parsed variable values; do not execute the action 
```

### Action-specific options

Typically, a pipeline will expose a series of action-specific options. 
These are listed first and can be specified at the command line in short, 
e.g., '-i', or long, e.g., '--input-dir', format. 
Long format names are used in data.yml files.

For clarity of organization and ease of reuse, options are organized into "families",
leading to data.yml files with entries like:

```yml
# data.yml
align: # the pipeline action
    fastq-input: # the option family
        input-dir: /data/path # a single option value
```

### Standard options

Other options are either mandated or offered by the MDI pipelines framework
and automatically added to all pipeline actions. They are too numerous to 
repeat here (see above), but two are critically important as they are how all MDI pipelines know where to write their output files:

- **output-dir** = the destination directory for an analysis project
- **data-name** = the sub-folder in --output-dir for each sample analyzed

Thus, the following job configuration file snippet:

```yml
# data.yml
align:
    output:
        output-dir: /project/path
        data-name: 
            - sample_1
            - sample_2
```

would write output for two analyzed samples to folders:

- /project/path/sample_1
- /project/path/sample_2

Among other useful common options, '--dry-run' allows a 
test of the action and options configuration prior to actual execution.
Every pipeline can also use parallel processing via options '--n-cpu' and 
'--ram-per-cpu', if supported by the pipeline developer.
