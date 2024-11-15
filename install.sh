#!/bin/bash

#---------------------------------------------------------------------------
# MDI command line installation utility
#---------------------------------------------------------------------------

# -----------------------------------------------------------------------
# ensure that we are working in an 'mdi' directory that contains this script
# -----------------------------------------------------------------------
export MDI_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [[ "$MDI_DIR" != */mdi ]]; then
    echo
    echo "ERROR - this script must be run from within an 'mdi' folder than contains it"
    echo
    exit 1
fi
cd $MDI_DIR

# -----------------------------------------------------------------------
# prompt for the requested installation action
# -----------------------------------------------------------------------
ACTION_NUMBER=$1
if [ "$ACTION_NUMBER" = "" ]; then
    echo
    echo "Welcome to the Michigan Data Interface installer."
    echo
    echo "Stage 2 apps installation may take many minutes. Select option 1 if you"
    echo "do not intend to use interactive web tools from this MDI installation."
    echo
    echo "Installation will populate this directory:"
    echo "  $MDI_DIR"
    echo
    echo "For more information, see: https://midataint.github.io/"    
    echo
    echo "What would you like to install?"
    echo
    echo "  1 - MDI Stage 1 pipelines only; Stage2 apps will be skipped"
    echo "  2 - both Stage 1 pipelines and Stage 2 apps (requires R)"
    echo "  3 - exit and do nothing"
    echo
    read -p "Select an action by its number: " ACTION_NUMBER
fi
echo

# -----------------------------------------------------------------------
# function to install the MDI by a call to mdi::install() in system R
# -----------------------------------------------------------------------
function run_mdi_install {
    CHECKOUT="NULL"
    if [[ "$SUITE_NAME" != "" && "$SUITE_VERSION" != "" ]]; then
        CHECKOUT="list(suites = list('$SUITE_NAME' = '$SUITE_VERSION'))"
    fi

    # note: we do not offer "config >> R_load_command" as it can make R version tracking ambiguous
    # most users have R pre-installed, otherwise they must pre-execute a command to load it
    # local batch scripts do allow users to specify an R load command in a wrapper of this script
    R_COMMAND=`command -v Rscript`
    if [ "$R_COMMAND" = "" ]; then
        echo -e "\nFATAL: R program targets not found"
        echo -e "please install or load R as required on your system"
        echo -e "    e.g., module load R/0.0.0\n"
        exit 1
    fi
    
    # execute the multi-step R-based MDI install sequence: remotes, git2r, mdi-manager, mdi::install()
    CRAN_REPO=https://repo.miserver.it.umich.edu/cran/
    R_VERSION=`Rscript --version | perl -ne '$_ =~ m/version\s+(\d+\.\d+)/ and print $1'`
    LIB_PATH=$MDI_DIR/library/R-$R_VERSION # install remotes and mdi-manager R package here (no Bioconductor suffix)
    mkdir -p $LIB_PATH
    Rscript -e \
".libPaths('$LIB_PATH'); x <- 'remotes'; \
if (!require(x, character.only = TRUE)){ \
    Ncpus <- Sys.getenv('N_CPU'); \
    if(Ncpus == '') Ncpus <- 1; \
    message(paste('Ncpus =', Ncpus)); \
    install.packages(x, repos = '$CRAN_REPO', Ncpus = Ncpus) \
}"
    Rscript -e ".libPaths('$LIB_PATH'); remotes::install_github('ropensci/git2r', ref = 'v0.33.0')" # enforce last git2r version with embedded libgit2
    Rscript -e ".libPaths('$LIB_PATH'); remotes::install_github('MiDataInt/mdi-manager')"
    Rscript -e ".libPaths('$LIB_PATH'); mdi::install('$MDI_DIR', installPackages = $INSTALL_PACKAGES, confirm = FALSE, checkout=$CHECKOUT)" # permission was granted above
}

# -----------------------------------------------------------------------
# functions to install Stage 1 pipelines only ...
# -----------------------------------------------------------------------
function install_pipelines_no_R { # ... without requiring system R; does not install forks

    # initialize the MDI directory tree
    echo "initializing the MDI file tree"
    mkdir -p config # populated below
    mkdir -p data   # unused, this is a pipelines-only installation
    mkdir -p containers   # populated by Stage 1 pipeline execution
    if [ "$SUITE_NAME" != "" ]; then 
        mkdir -p containers/$SUITE_NAME/library
    fi
    mkdir -p environments # populated by Stage 1 pipelines conda create
    mkdir -p frameworks/definitive      # populated below
    mkdir -p frameworks/developer-forks # unused, pipelines-only installation assumed to be an end user
    mkdir -p library   # unused, this is a pipelines-only installation
    mkdir -p remote    # populated below
    mkdir -p resources # populated by user as needed
    mkdir -p sessions  # unused, this is a pipelines-only installation
    mkdir -p suites/definitive      # populated by user via mdi add or other means
    mkdir -p suites/developer-forks # unused, pipelines-only installation assumed to be an end user

    # clone/pull the mdi-manager repository to access its file resources
    echo "cloning/updating the mdi-manager repository"
    function updateRepo {
        PARENT_FOLDER=$1
        GIT_REPO=$2
        CHECKOUT=$3
        REPO_NAME=`echo $GIT_REPO | sed 's/.*\///'`
        FOLDER=$PARENT_FOLDER/$REPO_NAME
        echo $FOLDER
        if [ -d $FOLDER ]; then
            cd $FOLDER
            git checkout main
            git pull
        else
            cd $PARENT_FOLDER
            git clone https://github.com/$GIT_REPO.git
            if [ $? -ne 0 ]; then exit 1; fi
            cd $REPO_NAME
        fi
        if [ "$CHECKOUT" = "latest" ]; then
            CHECKOUT=`
                git tag | 
                grep -P '^v\d+\.\d+\.\d+' | 
                sed -e 's/v//' -e 's/\\./\\t/g' | 
                sort -k1,1nr -k2,2nr -k3,3nr | 
                head -n1 | 
                awk '{print "v"$1"."$2"."$3}'` # the latest tagged version, method robust to all contingencies
		if [ "$CHECKOUT" = "" ]; then CHECKOUT="main"; fi
        fi
        echo "checking out $CHECKOUT"
        git -c advice.detachedHead=false checkout $CHECKOUT
        cd $MDI_DIR
    }
    MDI_MANAGER=mdi-manager
    updateRepo $MDI_DIR MiDataInt/$MDI_MANAGER main

    # initialize the installation config files if missing, but do not overwrite existing
    echo "initializing config files"
    INST_CONFIG=$MDI_MANAGER/inst/config
    function cpConfigFile {
        SOURCE=$INST_CONFIG/$1
        DESTINATION=config/$1
        if [ ! -e $DESTINATION ]; then cp $SOURCE $DESTINATION; fi
    }
    CONFIG_FILES=`ls -1 $INST_CONFIG`
    for CONFIG_FILE in $CONFIG_FILES; do cpConfigFile $CONFIG_FILE; done

    # initialize/update the remote server scripts
    echo "initializing remote scripts"
    cp -f $MDI_MANAGER/inst/remote/* remote 

    # initialize/update the mdi command line utility   
    echo "initializing 'mdi' command line utility"
    cp -f $MDI_MANAGER/inst/mdi mdi   
    chmod ug+x mdi 

    # clone/pull the definitive framework repositories
    echo "cloning/updating the mdi framework repositories"
    PIPELINES_FRAMEWORK=mdi-pipelines-framework
    APPS_FRAMEWORK=mdi-apps-framework
    FRAMEWORKS_DIR=$MDI_DIR/frameworks/definitive
    updateRepo $FRAMEWORKS_DIR MiDataInt/$PIPELINES_FRAMEWORK latest
    updateRepo $FRAMEWORKS_DIR MiDataInt/$APPS_FRAMEWORK latest

    # clone/pull any tool suites from config.yml
    echo "cloning/updating requested tool suites"
    export SUITES=`
        grep -v "^\s*#" config/suites.yml | 
        grep -v "^---" | 
        sed -e 's/^\s*-\s*//' -e 's/suites:\s*//' -e 's/#.*//' -e "s/^https:\/\/github.com\///" -e "s/\.git$//" | 
        grep "\S"
    `
    SUITES_DIR=$MDI_DIR/suites/definitive
    for GIT_REPO in $SUITES; do 
        REPO_VERSION=latest # checkout latest unless a version-specific suite-centric build/install
        if [ "$GIT_REPO" = "$GIT_USER/$SUITE_NAME" ] && [ "$SUITE_VERSION" != "" ]; then 
            REPO_VERSION=$SUITE_VERSION
        fi
        updateRepo $SUITES_DIR $GIT_REPO $REPO_VERSION
    done

    # clone/pull any additional tool suite dependencies from suite _config.yml files
    echo "cloning/updating tool suite dependencies"
    DEPENDENCIES=`
        cat $SUITES_DIR/*/_config.yml 2>/dev/null | 
        perl -e '
            my $inDep = 0;
            my %suites = map {$_ => 1} split(/\s+/, $ENV{SUITES});
            while(<>){
                if($_ =~ m/^suite_dependencies/){ $inDep = 1 } 
                elsif($_ =~ m/^\S/){ $inDep = 0 }
                elsif($inDep and $_ =~ m|^\s+-\s+(\S+)|){
                    $suites{$1} or print $1, "\n";
                }
            }
        ' | 
        sort | 
        uniq
    `
    for GIT_REPO in $DEPENDENCIES; do 
        updateRepo $SUITES_DIR $GIT_REPO latest
    done

    # initialize the pipelines jobManager
    JOB_MANAGER_DIR=$FRAMEWORKS_DIR/$PIPELINES_FRAMEWORK/job_manager
    perl $JOB_MANAGER_DIR/initialize.pl $MDI_DIR
    if [ $? -ne 0 ]; then exit 1; fi

    # remove tmp mdi-manager clone used for source files - the R mdi package is installed from GitHub
    rm -rf $MDI_MANAGER
}
function install_pipelines_only {
    if [ "$INSTALL_MDI_FORKS" = "" ]; then
        install_pipelines_no_R # allow end users to bypass R
    else 
        INSTALL_PACKAGES="FALSE" # but developers must have R to coordinate forks using mdi::install
        run_mdi_install
    fi
}

# -----------------------------------------------------------------------
# function to check for valid singularity
#   NOTE 2022-04-05: disabled mdi-singularity-base due to stddef.h out-of-date issues
# -----------------------------------------------------------------------
function set_singularity_version_ {
    export SINGULARITY_VERSION=`singularity --version 2>/dev/null | grep -P '^singularity.+version.+'`
}
function set_singularity_version {
    : # do nothing
    # set_singularity_version_ # use system singularity if present
    # if [ "$SINGULARITY_VERSION" = "" ]; then # otherwise attempt to load it
    #     CONFIG_FILE=$MDI_DIR/config/singularity.yml
    #     if [ -f $CONFIG_FILE ]; then
    #         LOAD_COMMAND=`grep -P '^load-command:\s+' $CONFIG_FILE | sed -e 's/\"//g' -e 's/load-command:\s*//' | grep -v null | grep -v '~'`
    #         if [ "$LOAD_COMMAND" != "" ]; then
    #             $LOAD_COMMAND > /dev/null 2>&1
    #             set_singularity_version_
    #         fi
    #     fi
    # fi 
}

# -----------------------------------------------------------------------
# install Stage 1 pipelines only; R is not required
# -----------------------------------------------------------------------
if [ "$ACTION_NUMBER" = "1" ]; then
    install_pipelines_only
    echo DONE

# -----------------------------------------------------------------------
# Stage 2 apps requested - determine how to install (container vs. system R)
# -----------------------------------------------------------------------
elif [ "$ACTION_NUMBER" = "2" ]; then
    if [ "$MDI_FORCE_SYSTEM_INSTALL" = "" ]; then
        set_singularity_version
    fi

# -----------------------------------------------------------------------
# Singularity not found: use full system-R mdi::install() from mdi-manager package
# this path forced by MDI_FORCE_SYSTEM_INSTALL during container build
#   NOTE 2022-04-05: this path now forced for all Stage 2 installations
# -----------------------------------------------------------------------
    if [ "$SINGULARITY_VERSION" = "" ]; then 
        INSTALL_PACKAGES="TRUE"        
        run_mdi_install
        echo DONE

# -----------------------------------------------------------------------
# Singularity found: use mdi-singularity-base to install only missing packages
#   NOTE 2022-04-05: disabled mdi-singularity-base due to stddef.h out-of-date issues
# -----------------------------------------------------------------------
    else 
        echo "ERROR: support for mdi-singularity-base has been disabled"
        exit 1

    #     # query for the required R version if not provided in environment
    #     if [ "$MDI_R_VERSION" = "" ]; then
    #         echo
    #         echo "Singularity is available on system and will be used to speed"
    #         echo "installation of Stage 2 apps."
    #         echo
    #         echo "The installer needs to know which R-versioned container to download."
    #         echo "https://github.com/MiDataInt/mdi-singularity-base/pkgs/container/mdi-singularity-base"
    #         echo
    #         read -p "Please enter a major.minor R version (e.g., 4.1): " MDI_R_VERSION
    #     fi
    #     HAS_V=`echo $MDI_R_VERSION | grep '^v'`
    #     if [ "$HAS_V" = "" ]; then MDI_R_VERSION="v$MDI_R_VERSION"; fi
        
    #     # install Stage 1
    #     install_pipelines_only

    #     # (re)pull the container base image
    #     BASE_NAME=mdi-singularity-base
    #     CONTAINERS_DIR=$MDI_DIR/containers
    #     IMAGE_DIR=$CONTAINERS_DIR/$BASE_NAME
    #     mkdir -p $IMAGE_DIR
    #     IMAGE_FILE=$IMAGE_DIR/$BASE_NAME-$MDI_R_VERSION.sif
    #     IMAGE_URI=oras://ghcr.io/MiDataInt/$BASE_NAME:$MDI_R_VERSION
    #     if [ ! -e $IMAGE_FILE ]; then
    #         singularity pull $IMAGE_FILE $IMAGE_URI
    #     fi 
        
    #     # run mdi::extend() within a base container instance with bind-mount to $MDI_DIR
    #     # R Shiny library comes from container, suite packages compiled by container into containers/library
    #     singularity run --bind $MDI_DIR:/srv/active/mdi $IMAGE_FILE extend
    #     echo DONE
    fi
fi
