#!/bin/bash
# Install R/RStudio Server/Shiny Server nginx on Ubuntu

# Exit on error
set -e

# Setting up logging
LOG_FILE=$HOME/install-rstudioshinynginx.log
touch "$LOG_FILE" || { echo "Cannot write to log file: $LOG_FILE"; exit 1; }
log() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}
log "Starting installation of R, RStudio Server, Shiny Server and nginx..."

# Add CRAN repository to APT sources
log "Adding CRAN repository..."
if [[ $(lsb_release -is) == "Ubuntu" ]]
then
    echo "Linux distribution is Ubuntu, proceeding to add R repository to APT"
    sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y
else
    echo "Non-compatible Linux distribution, please seek further instructions on how to install R here https://cloud.r-project.org/bin/linux/"
    exit 1
fi

# Add CRAN repository key
log "Adding CRAN repository key..."
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Update repository list and install R
log "Installing R..."
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Install RStudio Server
log "Installing RStudio Server dependencies..."
sudo apt-get install gdebi-core -y
log "Downloading RStudio Server..."
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
log "Installing RStudio Server..."
sudo gdebi --non-interactive rstudio-latest.deb
log "Cleaning up RStudio Server..."
rm rstudio-latest.deb

# Install nginx
log "Installing nginx..."
sudo apt-get install nginx -y

# Configure nginx with RStudio Server and Shiny Server redirects
log "Downloading and installing pre-configured nginx config..."
sudo wget https://raw.githubusercontent.com/jb2cool/RStudioShiny-nginx/main/default -O /etc/nginx/sites-enabled/default

# Install Shiny R package
log "Find R version..."
R_VERSION=$(R --version | head -n 1 | grep -oP '\d+\.\d+'
log "Create personal R repository directory..."
mkdir -p ~/R/x86_64-pc-linux-gnu-library/$R_VERSION
log "Installing Shiny R package into personal repository..."
R -e "install.packages('shiny', repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/$R_VERSION')"

# Install Shiny Server
log "Installing cURL..."
sudo apt-get install curl -y
log "Finding latest Shiny Server version..."
SHINY_VERSION=$(curl -s https://download3.rstudio.org/ubuntu-18.04/x86_64/VERSION)
log "Downloading Shiny Server..."
wget --no-verbose "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-$SHINY_VERSION-amd64.deb" -O shiny-server-latest.deb
log "Installing Shiny Server..."
sudo gdebi -n shiny-server-latest.deb
log "Cleaning up Shiny Server..."
rm shiny-server-latest.deb

# Configure Shiny Server
log "Configuring Shiny Server..."
sudo sed -i "s/run_as shiny/run_as $USER/" /etc/shiny-server/shiny-server.conf
sudo sed -i "s/3838;/ 3838 0.0.0.0;/" /etc/shiny-server/shiny-server.conf
sudo sed -i "s/site_dir \/srv\/shiny-server/site_dir \/home\/$USER\/shiny/" /etc/shiny-server/shiny-server.conf
if grep -q sanitize_errors /etc/shiny-server/shiny-server.conf
then
    echo "Additional Shiny config already completed"
else
    sudo sed -i '/directory_index on;$/a \ \ \ \ sanitize_errors off;\n \ \ \ disable_protocols xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile;' /etc/shiny-server/shiny-server.conf
fi
log "Create Shiny Server site directory..."
mkdir $HOME/shiny

# Copy sample apps to users new Shiny dir
log "Copy sample apps to new Shiny Server site directory..."
cp -r /opt/shiny-server/samples/sample-apps/hello/ ~/shiny

# Restart services
log "Reloading nginx service..."
sudo systemctl reload nginx
log "Restart Shiny Server service..."
sudo systemctl restart shiny-server

# Clean up install script
log "Cleaning up install script..."
rm install-rstudioshinynginx.sh

# Tell user everything works
log "End of install output to user..."
echo ""
echo ""
echo "#######################################################################################"
echo "# nginx is now hosting a webpage on http://127.0.0.1                                  #"
echo "# RStudio Server is now available on http://127.0.0.1:8787 & http://127.0.0.1/rstudio #"
echo "# Shiny Server is now available on http://127.0.0.1:3838 & http://127.0.0.1/shiny     #"
echo "#######################################################################################"
echo ""
echo ""

# Cleaning up logging
echo "If you made it this far you probably don't need to keep the installation log file"
rm -i $LOG_FILE
