#!/bin/bash


# ========== ORGANISATION SPECFIC CONFIGURATION PROPERTIES =========== #

## ~~~~~~~~~~~~~~~~~ AMEND FOR YOUR ORANGISATION ~~~~~~~~~~~~~~~~~~~~~##
##                      ______________________                        ##

# The SSH or HTTPS URL to clone the modules repo
MODULES_GIT_REPO_URL=git@github.com:diethardsteiner/pentaho-pdi-modules.git
# **Note**: If this repo is not present yet, use this script 
# to create it and push it to your Git Server (GitHub, etc).

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##



## ~~~~~~~~~~~~~~~~~~~~~~~~~ DO NOT CHANGE ~~~~~~~~~~~~~~~~~~~~~~~~~~~##
##                      ______________________                        ##


if [ $# -eq 0 ] || [ -z "$1" ]
  then
    echo "ERROR: Not all mandatory arguments supplied, please supply environment and/or job arguments"
    echo
    echo "Usage: initialise-repo.sh ..."
    echo "Creates a basic folder structure for a code repository"
    echo 
    echo "Mandatory arguments"
    echo
    echo "-a   ACTION: Choose number"
    echo "        (1) Project Repo with Common Config and Modules"
    echo "        (2) Standalone Project and Config (No Common Artefacts)"
    echo "        pdi_module"
    echo "        pdi_module_repo"
    echo "        project_code"
    echo "        project_config"
    echo "        standalone_project_config"
    echo "        common_code"
    echo "        common_config"
    echo "        project_docu"
    echo "        common_docu"
    echo " "
    echo "Optional arguments:"
    echo " "
    echo "-p  PROJECT NAME:  Lower case, only letters allowed, no underscores, dashes etc."
    echo "                   Minimum of 3 to a maximum of 20 letters."
    echo "-e  ENVIRONMENT:   Name of the environment: dev, test, prod or similiar. "
    echo "                   Lower case, only letters allowed, no underscores, dashes etc"
    echo "                   Minimum of 3 to a maximum of 10 letters."
    echo "-s  STORAGE TYPE:  Which type of PDI storage type to use."
    echo "                   Possible values: file-based, file-repo. Not supported: db-repo, ee-repo"
    echo ""
    echo "Sample usage:"
    echo "initialise-repo.sh -a standalone_project_config -p mysampleproj -e dev -s file-based"
    echo "initialise-repo.sh -a 2 -p mysampleproj -e dev -s file-repo"
    echo ""
    echo "exiting ..."
    exit 1
fi


# while getopts ":a:p:d:u:" opt; do
while getopts ":a:p:e:s:" opt; do
  case $opt in
    a) ACTION="$OPTARG"
        echo "Submitted action value: ${ACTION}"
    ;;
    p) PROJECT_NAME="$OPTARG"
        echo "Submitted project name value: ${PROJECT_NAME}"
        if [[ ! ${PROJECT_NAME} =~ ^[a-z]{3,20}$ ]]; then
          echo "Unsupported project name!"
          echo "Lower case, only letters allowed, no underscores, dashes, spaces etc."
          echo "Minimum of 3 to a maximum of 20 letters."
          exit 1
        fi
    ;;
    e) PDI_ENV="$OPTARG"
        echo "Submitted environment value: ${PDI_ENV}" 
        if [[ ! ${PDI_ENV} =~ ^[a-z]{3,10}$ ]]; then
          echo "Unsupported environment name!"
          echo "Lower case, only letters allowed, no underscores, dashes, spaces etc."
          echo "Minimum of 3 to a maximum of 10 letters."
          exit 1
        fi
    ;;
    s) PDI_STORAGE_TYPE="$OPTARG"
        echo "Submitted environment value: ${PDI_STORAGE_TYPE}" 
        # check that supplied value is in the list of possible values
        # validate() { echo "files file-repo ee-repo" | grep -F -q -w "${PDI_STORAGE_TYPE}"; }
        LIST_CHECK=$(echo "file-based file-repo ee-repo" | grep -F -q -w "${PDI_STORAGE_TYPE}" && echo "valid" || echo "invalid")
        echo "List check: ${LIST_CHECK}"
        if [ ${LIST_CHECK} = "invalid" ]; then
          echo "Unsupported storage type!"
          echo "Possible values: file-based, file-repo, ee-repo"
          exit 1
        fi
    ;;
    \?) 
      echo "Invalid option -$OPTARG" >&2
      exit 1
    ;;
  esac
done

# Example Usage:
# /home/dsteiner/git/pentaho-standardised-git-repo-setup/utilities/shell-scripts/initialise-repo.sh -a standalone_project_config -p mysampleproj -e dev -s file-based
# /home/dsteiner/git/pentaho-standardised-git-repo-setup/utilities/shell-scripts/initialise-repo.sh -a 2 -p mysampleproj -e dev -s file-based
# /home/dsteiner/git/pentaho-standardised-git-repo-setup/utilities/shell-scripts/initialise-repo.sh -a 2 -p mysampleproj -e dev -s file-repo


# Main Script

WORKING_DIR=`pwd`
SHELL_DIR=$(dirname $0)
BASE_DIR=${WORKING_DIR}

echo "=============="
echo "SHELL DIR: " ${SHELL_DIR}
echo "BASE_DIR: " ${BASE_DIR}

# Source required helper scripts

#source ${SHELL_DIR}/add-pdi-respository.sh
function add_pdi_repository {
  
  PDI_REPOSITORY_FILE=$1
  PDI_REPO_BASE_DIR=$2

  
  echo "Submitted repository file path value: ${PDI_REPOSITORY_FILE}"
  echo "Submitted project name value: ${PROJECT_NAME}"
  echo "Submitted pdi repo base dir value: ${PDI_REPO_BASE_DIR}" 

  # if repositories.xml exists in common config folder already:
  #   check if repo is already defined
  #   if not add it
  if [ -d "${PDI_REPOSITORY_FILE}" ]; then
  # sublime has some syntax highlighting issues if EOL is indented, so not indenting here
  REPO_CHECK=$(grep "<name>${PROJECT_NAME}</name>"  ${PDI_REPOSITORY_FILE})
  if [REPO_CHECK = "" ]; then
    echo "Adding repository reference to existing repository registry ..."
    # remove existing repositories end tag
    perl -0777 -pe 's@</repositories>@@igs' -i ${PDI_REPOSITORY_FILE}
    # add new repository details and new repositories end tag
  cat > ${PDI_REPOSITORY_FILE} <<EOL
  <repository>    
    <id>KettleFileRepository</id>
    <name>${PROJECT_NAME}</name>
    <description>${PROJECT_NAME}</description>
    <is_default>false</is_default>
    <base_directory>${PDI_REPO_BASE_DIR}</base_directory>
    <read_only>N</read_only>
    <hides_hidden_files>N</hides_hidden_files>
  </repository>
</repositories>
EOL
else
  echo "Project already part of the repository registry. Nothing to do ... moving on ..."
fi
else
# if not:
#   add the whole file
echo "Adding new repository registry ..."
cat > ${PDI_REPOSITORY_FILE} <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<repositories>
  <repository>    
    <id>KettleFileRepository</id>
    <name>${PROJECT_NAME}</name>
    <description>${PROJECT_NAME}</description>
    <is_default>false</is_default>
    <base_directory>${PDI_REPO_BASE_DIR}</base_directory>
    <read_only>N</read_only>
    <hides_hidden_files>N</hides_hidden_files>
  </repository>
</repositories>
EOL
fi
}

function pdi_module {
  # check if required parameter values are available
  if [ -z ${ACTION} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "exiting ..."
    exit 1
  fi
  echo "================PDI MODULES===================="
  PDI_MODULES_DIR=${BASE_DIR}/modules
  echo "PDI_MODULES_DIR: ${PDI_MODULES_DIR}" 
  if [ ! -d "${PDI_MODULES_DIR}" ]; then
    echo "Creating PDI modules folder ..."
    mkdir ${PDI_MODULES_DIR}
    cd ${PDI_MODULES_DIR}
    echo "Initialising Git Repo ..."
    git init .
    # git hooks wont work here since the directory structure is different
    # echo "Adding Git hooks ..."
    # cp ${SHELL_DIR}/artefacts/git-hooks/* ${PDI_MODULES_DIR}/.git/hooks
    # we have to create a file so that the master branch is created
    echo "creatng README file ..."
    touch README.md
    echo "adding module_1 sample module ..."
    cp -r ${SHELL_DIR}/artefacts/pdi/repo/module_1 .
    git add --all
    git commit -am "initial commit"
  fi
}

function pdi_module_repo {
  # check if required parameter values are available
  if [ -z ${ACTION} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "exiting ..."
    exit 1
  fi
  echo "================PDI MODULES REPO===================="
  PDI_MODULES_REPO_DIR=${BASE_DIR}/modules-pdi-repo
  echo "PDI_MODULES_REPO_DIR: ${PDI_MODULES_REPO_DIR}"
  if [ ! -d "${PDI_MODULES_REPO_DIR}" ]; then
    echo "Creating PDI modules repo folder ..."
    mkdir ${PDI_MODULES_REPO_DIR}
    echo "Initialising Git Repo ..."
    cd ${PDI_MODULES_REPO_DIR}
    git init .
    echo "Adding Git hooks ..."
    cp ${SHELL_DIR}/artefacts/git-hooks/* ${PDI_MODULES_REPO_DIR}/.git/hooks
    echo "Adding kettle db connection files ..."
    cp -r ${SHELL_DIR}/artefacts/pdi/repo/*.kdb .
    echo "Adding pdi modules as a git submodule ..."
    git submodule add -b master ${MODULES_GIT_REPO_URL} modules
    # the next command is only required in older git versions to get the content for the submodule
    git submodule init
    git submodule update

    # enable pre-commit hook
    chmod 700 ${PDI_MODULES_REPO_DIR}/.git/hooks/pre-commit
  fi 
}

function project_code {
  # check if required parameter values are available
  if [ -z ${ACTION} ] || [ -z ${PROJECT_NAME} ] || [ -z ${PDI_STORAGE_TYPE} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "-p <Project Name>"
    echo "-s <PDI Storage Type>"
    echo "exiting ..."
    exit 1
  fi
  echo "================PROJECT CODE===================="
  PROJECT_CODE_DIR=${BASE_DIR}/${PROJECT_NAME}-code
  echo "PROJECT_CODE_DIR: ${PROJECT_CODE_DIR}"
  if [ ! -d "${PROJECT_CODE_DIR}" ]; then
    echo "Creating project code folder ..."
    echo "location: ${PROJECT_CODE_DIR}" 
    mkdir ${PROJECT_CODE_DIR}
    cd ${PROJECT_CODE_DIR}
    echo "Initialising Git Repo ..."
    git init .

    echo "Adding Git hooks ..."
    cp ${SHELL_DIR}/artefacts/git-hooks/* ${PROJECT_CODE_DIR}/.git/hooks
    perl -0777 \
      -pe "s@\{\{ IS_CONFIG \}\}@N@igs" \
      -i ${PROJECT_CODE_DIR}/.git/hooks/pre-commit 
    if [ ${PDI_STORAGE_TYPE} = "file-based" ]; then
      perl -0777 \
        -pe "s@\{\{ IS_REPO_BASED \}\}@N@igs" \
        -i ${PROJECT_CODE_DIR}/.git/hooks/pre-commit
    else
      perl -0777 \
        -pe "s@\{\{ IS_REPO_BASED \}\}@Y@igs" \
        -i ${PROJECT_CODE_DIR}/.git/hooks/pre-commit
    fi

    echo "Creating and pointing to default git branch"
    git checkout -b dev
    
    echo "Creating basic folder structure ..."
    mkdir pdi
    mkdir -p pentaho-server/metadata 
    mkdir -p pentaho-server/mondrian
    mkdir prd
    mkdir shell-scripts
    mkdir -p sql/ddl

    echo "Creating basic README file ..."
    echo "Documentation can be found in the dedicated documentation Git repo called ${PROJECT_NAME}-documentation" > README.md

    if [ ${PDI_STORAGE_TYPE} = "file-repo" ]; then
      echo "Adding kettle db connection files ..."
      cp -r ${SHELL_DIR}/artefacts/pdi/repo/*.kdb pdi
    fi
    
    if [ ${PDI_STORAGE_TYPE} = "file-based" ]; then
      # nothing to do: shared.xml is part of .kettle, which lives in the config repo
      echo ""
    fi
    
    echo "Adding pdi modules as a git submodule ..."
    
    git submodule add -b master ${MODULES_GIT_REPO_URL} pdi/modules
    git submodule init
    git submodule update
    
    echo "Setting branch for submodule ..."
    
    cd pdi/modules
    git checkout master
    cd ../..
    
    echo "Committing new files ..."
    
    git add --all
    git commit -am "initial commit"

    # enable pre-commit hook
    chmod 700 ${PROJECT_CODE_DIR}/.git/hooks/pre-commit

  fi
}

function project_config {
  # check if required parameter values are available
  if [ -z ${ACTION} ] || [ -z ${PROJECT_NAME} ] || [ -z ${PDI_ENV} ] || [ -z ${PDI_STORAGE_TYPE} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "-p <Project Name>"
    echo "-e <Environment>"
    echo "-s <PDI Storage Type>"
    echo "exiting ..."
    exit 1
  fi
  echo "================PROJECT CONFIG=================="
  PROJECT_CONFIG_DIR=${BASE_DIR}/${PROJECT_NAME}-config-${PDI_ENV}
  echo "PROJECT_CONFIG_DIR: ${PROJECT_CONFIG_DIR}"
  if [ ! -d "${PROJECT_CONFIG_DIR}" ]; then 
    echo "Creating project config folder ..."
    echo "location: ${PROJECT_CONFIG_DIR}" 
    mkdir ${PROJECT_CONFIG_DIR}
    cd ${PROJECT_CONFIG_DIR}
    echo "Initialising Git Repo ..."
    git init .
    echo "Adding Git hooks ..."
    cp ${SHELL_DIR}/artefacts/git-hooks/* ${PROJECT_CONFIG_DIR}/.git/hooks
    perl -0777 \
      -pe "s@\{\{ IS_CONFIG \}\}@Y@igs" \
      -i ${PROJECT_CONFIG_DIR}/.git/hooks/pre-commit 
    perl -0777 \
      -pe "s@\{\{ IS_REPO_BASED \}\}@N@igs" \
      -i ${PROJECT_CONFIG_DIR}/.git/hooks/pre-commit
    
    echo "Creating basic folder structure ..."
    
    mkdir -p pdi/metadata
    mkdir -p pdi/properties 
    mkdir -p pdi/schedules
    mkdir -p pdi/shell-scripts 
    mkdir -p pdi/test-data
    mkdir -p pentaho-server/connections
    
    echo "Adding essential shell files ..."
    
    cp ${SHELL_DIR}/artefacts/project-config/*.sh \
       ${PROJECT_CONFIG_DIR}/pdi/shell-scripts
    
    mv ${PROJECT_CONFIG_DIR}/pdi/shell-scripts/run_jb_name.sh \
       ${PROJECT_CONFIG_DIR}/pdi/shell-scripts/run_jb_${PROJECT_NAME}_master.sh
    
    echo "Adding essential properties files ..."
    
    cp ${SHELL_DIR}/artefacts/project-config/*.properties \
       ${PROJECT_CONFIG_DIR}/pdi/properties 
    
    # rename project properies file
    mv ${PROJECT_CONFIG_DIR}/pdi/properties/project.properties \
       ${PROJECT_CONFIG_DIR}/pdi/properties/${PROJECT_NAME}.properties
    
    touch ${PROJECT_CONFIG_DIR}/pdi/properties/jb_${PROJECT_NAME}_master.properties 
    
    # copy deployment scripts across
    # [OPEN]

    echo "Creating basic README file ..."
    echo "Project specific configuration for ${PDI_ENV} environment." > ${PROJECT_CONFIG_DIR}/README.md  

    # enable pre-commit hook
    chmod 700 ${PROJECT_CONFIG_DIR}/.git/hooks/pre-commit

  fi
}

function standalone_project_config {
  # This caters for projects that do not need a common project or config
  # check if required parameter values are available
  if [ -z ${ACTION} ] || [ -z ${PROJECT_NAME} ] || [ -z ${PDI_ENV} ] || [ -z ${PDI_STORAGE_TYPE} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "-p <Project Name>"
    echo "-e <Environment>"
    echo "-s <PDI Storage Type>"
    echo "exiting ..."
    exit 1
  fi
  
  project_config

  echo "Adding essential shell files ..."
  
  cp ${SHELL_DIR}/artefacts/common-config/set-env-variables.sh \
     ${PROJECT_CONFIG_DIR}/pdi/shell-scripts
  
  perl -0777 \
    -pe "s@\{\{ KETTLE_HOME \}\}@${PROJECT_CONFIG_DIR}@igs" \
    -i ${PROJECT_CONFIG_DIR}/pdi/shell-scripts/set-env-variables.sh 

  # add_kettle_artefacts
  echo "Adding .kettle files for ${PDI_STORAGE_TYPE} ..."
  mkdir .kettle
  cp ${SHELL_DIR}/artefacts/pdi/.kettle/kettle.properties \
     pdi/.kettle

  if [ ${PDI_STORAGE_TYPE} = 'file-repo' ]; then
    add_pdi_repository \
      "${BASE_DIR}/${PROJECT_NAME}-config-${PDI_ENV}/pdi/.kettle/repositories.xml" \
      "${BASE_DIR}/${PROJECT_NAME}-code/pdi"
  fi

  if [ ${PDI_STORAGE_TYPE} = "file-based" ]; then
    
    cp ${SHELL_DIR}/artefacts/pdi/.kettle/shared.xml \
       pdi/.kettle
  fi

  echo ""
  echo "==============================="
  echo ""
  echo -e "\e[34m\e[47mIMPORTANT\e[0m"
  echo "Amend the following configuration file:"
  echo "${PROJECT_CONFIG_DIR}/shell-scripts/set-env-variables.sh"
  echo ""
  echo "Before using Spoon, source this file:"
  echo "source ${PROJECT_CONFIG_DIR}/shell-scripts/set-env-variables.sh"
  echo "==============================="
  echo ""

  echo "Running set-env-variables.sh now so that at least KETTLE_HOME is defined."
  echo "You can start PDI Spoon now if working on a dev machine."
  echo ""

  source ${PROJECT_CONFIG_DIR}/pdi/shell-scripts/set-env-variables.sh

}

# retired since we use modules now
# function common-code {
#   echo "==========COMMON CODE=================="
#   COMMON_CODE_DIR=${BASE_DIR}/common-code
#   if [ ! -d "${COMMON_CODE_DIR}" ]; then 
#     echo "Creating common config folder ..."
#     echo "location: ${COMMON_CODE_DIR}" 
#     mkdir ${COMMON_CODE_DIR}
#     cd ${COMMON_CODE_DIR}
#     echo "Initialising Git Repo ..."
#     git init .
#     echo "Creating Git Branch ${PDI_ENV} ..."
#     git checkout -b ${PDI_ENV}
#     echo "Creating basic folder structure ..."
#     mkdir pdi mdx mondrian-schemas pentaho-solutions sql
#     echo "Creating basic README file ..."
#     echo "Common code for ${PDI_ENV} environment. Find documentation in dedicated docu repo." > ${COMMON_CODE_DIR}/README.md
#   fi
# }

function common_config {
  # check if required parameter values are available
  if [ -z ${ACTION} ] || [ -z ${PDI_ENV} ] || [ -z ${PDI_STORAGE_TYPE} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "-e <Environment>"
    echo "-s <PDI Storage Type>"
    echo "exiting ..."
    exit 1
  fi
  echo "==========COMMON CONFIG=================="
  COMMON_CONFIG_DIR=${BASE_DIR}/common-config-${PDI_ENV}
  echo "COMMON_CONFIG_DIR: ${COMMON_CONFIG_DIR}"
  if [ ! -d "${COMMON_CONFIG_DIR}" ]; then 
    echo "Creating common config folder ..."
    echo "location: ${COMMON_CONFIG_DIR}" 
    mkdir ${COMMON_CONFIG_DIR}
    cd ${COMMON_CONFIG_DIR}
    echo "Creating basic folder structure ..."
    mkdir .kettle shell-scripts

    echo "Initialising Git Repo ..."
    git init .
    echo "Adding Git hooks ..."
    cp ${SHELL_DIR}/artefacts/git-hooks/* ${COMMON_CONFIG_DIR}/.git/hooks
    perl -0777 \
      -pe "s@\{\{ IS_CONFIG \}\}@Y@igs" \
      -i ${COMMON_CONFIG_DIR}/.git/hooks/pre-commit 
    perl -0777 \
      -pe "s@\{\{ IS_REPO_BASED \}\}@N@igs" \
      -i ${COMMON_CONFIG_DIR}/.git/hooks/pre-commit

    # add_kettle_artefacts

    echo "Adding .kettle files ..."
    
    cp ${SHELL_DIR}/artefacts/pdi/.kettle/kettle.properties .kettle
    if [ ${PDI_STORAGE_TYPE} = "file-repo" ]; then
      # cp ${SHELL_DIR}/artefacts/pdi/.kettle/repositories.xml .kettle
      add_pdi_repository \
        "${COMMON_CONFIG_DIR}/.kettle/repositories.xml" \
        "${BASE_DIR}/${PROJECT_NAME}-code/pdi"
    fi
    if [ ${PDI_STORAGE_TYPE} = "file-based" ]; then
      cp ${SHELL_DIR}/artefacts/pdi/.kettle/shared.xml \
         pdi/.kettle
    fi
    # ---
    echo "Adding essential shell files ..."

    cp ${SHELL_DIR}/artefacts/common-config/set-env-variables.sh \
       ${COMMON_CONFIG_DIR}/pdi/shell-scripts
    
    perl -0777 \
      -pe "s@\{\{ KETTLE_HOME \}\}@${COMMON_CONFIG_DIR}@igs" \
      -i ${COMMON_CONFIG_DIR}/pdi/shell-scripts/set-env-variables.sh 


    # enable pre-commit hook
    chmod 700 ${COMMON_CONFIG_DIR}/.git/hooks/pre-commit


    echo "Creating basic README file ..."
    echo "Common configuration for ${PDI_ENV} environment." > ${COMMON_CONFIG_DIR}/README.md

    echo ""
    echo "==============================="
    echo ""
    echo -e "\e[34m\e[47mIMPORTANT\e[0m"
    echo "Amend the following configuration file:"
    echo "${COMMON_CONFIG_DIR}/shell-scripts/set-env-variables.sh"
    echo ""
    echo ""
    echo "==============================="
    echo ""

    echo "Running set-env-variables.sh now so that at least KETTLE_HOME is defined."
    echo "You can start PDI Spoon now if working on a dev machine."
    echo ""

    source ${COMMON_CONFIG_DIR}/pdi/shell-scripts/set-env-variables.sh
  fi
}


function project_docu {
  # check if required parameter values are available
  if [ -z ${ACTION} ] || [ -z ${PROJECT_NAME} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "-p <Project Name>"
    echo "exiting ..."
    exit 1
  fi
  echo "===========PROJECT DOCUMENTATION=================="
  PROJECT_DOCU_DIR=${BASE_DIR}/${PROJECT_NAME}-documentation
  echo "PROJECT_DOCU_DIR: ${PROJECT_DOCU_DIR}"
  if [ ! -d "${PROJECT_DOCU_DIR}" ]; then 
    echo "Creating project documentation folder ..."
    echo "location: ${PROJECT_DOCU_DIR}"
    mkdir ${PROJECT_DOCU_DIR}
    cd ${PROJECT_DOCU_DIR}
    echo "Initialising Git Repo ..."
    git init .
    echo "Creating basic README file ..."
    echo "# Documentation for ${PROJECT_NAME}" > ${PROJECT_DOCU_DIR}/README.md
  fi
}

function common_docu {
  # check if required parameter values are available
  if [ -z ${ACTION} ]; then
    echo "Not all required arguments were supplied. Required:"
    echo "-a <Action>"
    echo "exiting ..."
    exit 1
  fi
  echo "===========COMMON DOCUMENTATION=================="
  COMMON_DOCU_DIR=${BASE_DIR}/common-documentation
  echo "COMMON_DOCU_DIR: ${COMMON_DOCU_DIR}"
  if [ ! -d "${COMMON_DOCU_DIR}" ]; then 
    echo "Creating project documentation folder ..."
    echo "location: ${COMMON_DOCU_DIR}"
    mkdir ${COMMON_DOCU_DIR}
    cd ${COMMON_DOCU_DIR}
    echo "Initialising Git Repo ..."
    git init .
    echo "Creating basic README file ..."
    echo "# Common Documentation" > ${COMMON_DOCU_DIR}/README.md
  fi
}



if [ ${ACTION} = "1" ]; then 
  project_code
  project_config
  common_config
  common_docu
  project_docu
fi

if [ ${ACTION} = "2" ]; then 
  project_code
  standalone_project_config
  project_docu
fi

if [ ${ACTION} = "pdi_module" ]; then 
  pdi_module
fi

if [ ${ACTION} = "pdi_module_repo" ]; then
  pdi_module_repo
fi

if [ ${ACTION} = "project_code" ]; then
  project_code
fi

if [ ${ACTION} = "project_config" ]; then
  project_config
fi

if [ ${ACTION} = "standalone_project_config" ]; then
  standalone_project_config
fi

if [ ${ACTION} = "common_config" ]; then
  common_config
fi

if [ ${ACTION} = "project_docu" ]; then
  project_docu
fi

if [ ${ACTION} = "common_docu" ]; then
  common_docu
fi