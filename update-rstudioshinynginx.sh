#!/bin/bash
# Update R/RStudio Server/Shiny Server/nginx on Ubuntu

# Exit on error
set -e

# Logging function
LOG_FILE="install-rstudioshinynginx.log"
log() {
    echo "[INFO] $1" | tee -a "$LOG_FILE"
}
log "Starting installation of R, Shiny Server, and nginx"

# Update repository list and install R
log "Installing latest version of R base"
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Update RStudio Server
log "Installing prerequisite package for RStudio Server"
sudo apt-get install gdebi-core -y
log "Downloading RStudio Server"
if [[ $(lsb_release -rs) == "20.04" ]]
then
    wget https://www.rstudio.org/download/latest/stable/server/focal/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
elif [[ $(lsb_release -rs) == "22.04" ]]
then
    wget https://www.rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
elif [[ $(lsb_release -rs) == "24.04" ]]
then
    wget https://www.rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
else
    echo "Non-compatible version"
fi
log "Installing RStudio Server"
sudo gdebi --non-interactive rstudio-latest.deb
log "Cleaning up RStudio Server"
rm rstudio-latest.deb

# Update nginx
log "Installing latest version of nginx"
sudo apt-get install nginx -y

# Update to latest version of Shiny Server
log "Installing prerequisite package for Shiny Server"
sudo apt-get install curl -y
log "Finding latest Shiny Server version"
SHINY_VERSION=$(curl -s https://download3.rstudio.org/ubuntu-18.04/x86_64/VERSION)
log "Downloading Shiny Server"
wget --no-verbose "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-$SHINY_VERSION-amd64.deb" -O shiny-server-latest.deb
log "Installing Shiny Server"
sudo gdebi -n shiny-server-latest.deb
log "Cleaning up Shiny Server"
rm shiny-server-latest.deb

# Clean up install log
log "Cleaning up install log"
