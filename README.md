# Getting Started

## Purpose

To understand what the project is about, have a look at the presentation in this repos' [presentation](./presentations/pcm2017.md). Read this before proceeding.

> **In a nutshell**: This project delivers a utility script which sets up potentially several Pentaho specific git repos with a predefined/standardised folder structure and utilises Git Hooks to enforce a few coding standards.

## Initial Setup


Clone the repo to your local machine: 

```bash 
git clone git@github.com:diethardsteiner/pentaho-standardised-git-repo-setup.git
cd pentaho-standardised-git-repo-setup
```

Next have to change the following file **for each project and environment** that you want to create the git skeleton for:

- `config/settings.sh`: Read comments in file to understand what the settings mean.

> **Note**: If the `MODULES_GIT_REPO_URL` repo is not present yet, use the `initialise-repo.sh` to create it and push it to your Git Server (GitHub, etc). Then adjust the configuration.


## Initialise Project Structure

The `initialise-repo.sh` can create:

- project-specific **config repo** for a given environment (`<proj>-conf-<env>`)
- common **config repo** for a given environment (`common-conf-<env>`)
- project **code repo** (`<proj>-code`)
- common **docu repo** (`common-documentation`)
- project **docu repo** (`<proj>-documentation`)
- PDI **modules** (`modules`): for reusable code/patterns. Holds plain modules only, so it can be use either in file-based or repo-based PDI setup.
- PDI **modules repo** (`modules-pdi-repo`): required when creating modules via PDI repo.
 
with the very basic folder structure and required artifacts. The script enables you to create them individually or combinations of certain repositories.

The `initialise-repo.sh` script expects following **arguments**:

- action (required)
- project name (not always required)
- environment (not always required)
- PDI file storage (not always required)

> **Important**: The project name must only include letters, no other characters. The same applies to the environment name.

> **Important**: All the repositories have to be located within the same folder. This folder is referred to as `BASE_DIR`.

> **Note**: If any of these repositories already exist within the same folder, they will not be overwritten. The idea is to run the script in a fresh/clean base dir, have to script create the repos and then push them to the central git server.

## Example

Creating a new **project** called `myproject` with **common artefacts** for the `dev` **environment** using a PDI file-based **storage approach** 

```bash
$ sh initialise-repo.sh -a 1 -p myproject -e dev -s file-based
```

Once this is in place, most settings should be automatically set, however, double check the following files and amend if required:

- `common-config-<env>/pdi/.kettle/repositories.xml` (only when using repo storage mode)
- `common-config-<env>/pdi/shell-scripts/set_env_variables.sh`
- `myproject-config-<env>/pdi/shell-scripts/wrapper.sh`: There are only changes required in the `PROJECT-SPECIFIC CONFIGURATION PROPERTIES` section.

If you are setting this up on your local workstation, you should be able to start Spoon now and connect to the PDI repository. 

> **Note**: Pay attention to the console output while running the script. There should be a line at the end saying how you can initialise the essential environment variables. You have to run this command before starting Spoon!

As the next step you might want to adjust:

- `common-config-<env>/pdi/.kettle/kettle.properties`
- `common-config-<env>/pdi/.kettle/shared.xml` (only when using file-based storage mode)
- `myproject-config-<env>/pdi/properties/myproject.properties`
- `myproject-config-<env>/pdi/properties/jb_myproject_master.properties`

Don't forget to commit all these changes. You will also have to set the Git remote for these repositories.

# Code Repository

## What is NOT Code

- **Configuration**: Goes into dedicated config repo by environment.
- **Documentation**: Goes into dedicated docu repo. 
- **Data**:
	- Lookup Data: E.g. business user provide you with lookup data to enrich operational data. This should be stored separately. 
	- Test Data: Can be stored with your code since it serves the purpose of testing the quality of your code.  
- **Binary files**: Excel, Word, Zip files etc