# RStudioShiny-nginx
## Wrapper script for installing R, RStudio Server, Shiny Server all behind an nginx reverse proxy

This script assumes you have a pretty clean Ubuntu 20.04 LTS install.

We will:
* Add the official R 4.0 respository
* Add the APT keys for this repository
* Install R (r-base and r-base-dev)
* Download and install RStudio Server
* Install and configure nginx (more on this below)
* Install the shiny R package
* Download and install Shiny Server
* Configure Shiny Server (more on this below)


Once complete you'll have:
* nginx default home page being served on port 80 (http://127.0.0.1)
* RStudio Server being served on port 8787 and also as a virtual directory (http://127.0.0.1:8787 & http://127.0.0.1/rstudio)
* Shiny Server being served on port 3838 and also as a virtual directory (http://127.0.0.1:3838 & http://127.0.0.1/shiny)
* Shiny Server is being run as the user that installed it (little bit weird but makes it easy for the user)
* Shiny Server is being run out of the users home directory (~/shiny) (little bit weird but makes it easy for the user)
* Shiny Server can host multiple apps and will present an initial index page, an index entry gets created for every folder in ~/shiny (If you only want to host a single app then just delete the sample app folder in ~/shiny and publish your application directly into there)

## Instructions
### Installation
Simply download and run the install-rstudioshinynginx.sh script. This should be as simple as:
```
wget https://raw.githubusercontent.com/jb2cool/RStudioShiny-nginx/master/install-rstudioshinynginx.sh
bash install-rstudioshinynginx.sh
```

### Updating
Occasionally you'll want to update to newer versions of R, RStudio Server, Shiny Server and nginx. R and nginx would likely have already been updated by your regular update schedule on your machine but since RStudio Server and Shiny Server were downloaded and installed manually these need a more manual approach to update them. Use the update script to update to the latest versions of all programs. Simply download and run the update-rstudioshinynginx.sh script. This should be as simple as:
```
wget https://raw.githubusercontent.com/jb2cool/RStudioShiny-nginx/master/update-rstudioshinynginx.sh
bash update-rstudioshinynginx.sh
```

## Cautions
* The install script will overwrite your /etc/nginx/sites-enabled/default file, if you have already made customisations to this file ensure you have a backup.
* The install script manually creates your R personal library, this shouldn't have any impact if you already have a personal library but it's untested.
* This is designed for ease-of-use on a single-user machine, if this is a multi-user machine then this is probably not the approach to take.
