#!/bin/bash
# Update R/RStudio Server/Shiny Server/nginx on Ubuntu

# Exit on error
set -e

# Setting up logging
LOG_FILE=$HOME/update-rstudioshinynginx.log
touch "$LOG_FILE" || { echo "Cannot write to log file: $LOG_FILE"; exit 1; }
log() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}
log "Starting update of R, RStudio Server, Shiny Server and nginx..."

# Update repository list and install R
log "Updating R..."
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Update RStudio Server
log "Downloading RStudio Server..."
sudo apt-get install gdebi-core -y
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
log "Updating RStudio Server..."
sudo gdebi --non-interactive rstudio-latest.deb
log "Cleaning up RStudio Server..."
rm rstudio-latest.deb

# Update nginx
log "Updating nginx..."
sudo apt-get install nginx -y

# Install Shiny R package
log "Find R version..."
R_VERSION=$(R --version | head -n 1 | grep -oP '\d+\.\d+')
log "Create personal R repository directory..."
mkdir -p ~/R/x86_64-pc-linux-gnu-library/$R_VERSION
log "Installing Shiny R package into personal repository..."
R -e "install.packages('shiny', repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/$R_VERSION')"

# Update to latest version of Shiny Server
log "Updating cURL..."
sudo apt-get install curl -y
log "Finding latest Shiny Server version..."
SHINY_VERSION=$(curl -s https://download3.rstudio.org/ubuntu-18.04/x86_64/VERSION)
log "Downloading Shiny Server version..."
wget --no-verbose "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-$SHINY_VERSION-amd64.deb" -O shiny-server-latest.deb
log "Installing Shiny Server..."
sudo gdebi -n shiny-server-latest.deb
log "Cleaning up Shiny Server..."
rm shiny-server-latest.deb

# Cleaning up logging
echo "If you made it this far you probably don't need to keep the update log file"
rm -i $LOG_FILE
