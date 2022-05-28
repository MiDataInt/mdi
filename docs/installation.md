---
title: "Installation"
has_children: false
nav_order: 10
---

## {{ page.title }}

Follow these instructions to create an "MDI-centric"
(as opposed to "suite centric") MDI installation, complete 
with managers, frameworks, and tool suites.

### Clone the MDI repo

```bash
git clone https://github.com/MiDataInt/mdi.git
```

### Run the installation script

```bash
cd mdi
./install.sh
```

Please read the menu options and confirm your installation choice.
A full installation including Stage 2 apps can take many minutes 
to complete. 

### OPTIONAL: Create an alias to the utility

The following commands will create an alias to the 'mdi' utility
in your new MDI installation for easy access from any folder.

```bash
./mdi alias --alias mdi # change the alias name as needed
`./mdi alias --alias mdi --get`
```

The second command activates the alias in the current shell also - or 
simply log back in.

You could also edit your profile to modify $PATH, but
we prefer aliases since we often maintain multiple MDI installations
that we refer to by different alias names.

### Configure and install tool suites

<code>install.sh</code> clones the MDI frameworks but few actual
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

Alternatively, run the following from the command line:

```bash
mdi add --help
mdi add -s GIT_USER/SUITE_NAME-mdi-tools # either format works
mdi add -s https://github.com/GIT_USER/SUITE_NAME-mdi-tools.git
```
