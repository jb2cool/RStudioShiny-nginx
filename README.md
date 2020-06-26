# RStudioShiny-nginx
Wrapper script for installing R, RStudio Server, Shiny Server all behind an nginx reverse proxy

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
* RStudio Server being served on port 8787 and also as a subdirectory (http://127.0.0.1:8787) http://127.0.0.1/rstudio)
* Shiny Server being served on port 3838 and also as a subdirectory (http://127.0.0.1:3838) http://127.0.0.1/shiny)
* Shiny Server is being run as the user that installed it
* Shiny Server is being run out of the users home directory (~/shiny)
* Shiny Server can host multiple apps and will present an index page 

Cautions
The install script will overwrite your /etc/nginx/sites-enabled/default file, if you have already made customisations ot this file ensure you have a backup.
