#!/bin/bash
# R/RStudio/Shiny-Server/nginx on Ubuntu

# Add repository to APT sources.list
echo deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/ | sudo tee --append /etc/apt/sources.list

# Add keys
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

# Update repository list and install R
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Install RStudio-Server
sudo apt-get install gdebi-core -y
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.959-amd64.deb
sudo gdebi --non-interactive rstudio-server-1.3.959-amd64.deb
rm rstudio-server-1.3.959-amd64.deb

# Install nginx
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure nginx with RStudio-Server and Shiny-Server virtualhosts
sudo wget https://raw.githubusercontent.com/jb2cool/RStudioShiny-nginx/master/default -O /etc/nginx/sites-enabled/

# Install Shiny R package
mkdir -p ~/R/x86_64-pc-linux-gnu-library/4.0
R -e "install.packages('shiny', repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/4.0')"

# Install Shiny-Server
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
sudo gdebi --non-interactive shiny-server-1.5.14.948-amd64.deb
rm shiny-server-1.5.14.948-amd64.deb

# Configure Shiny-Server
sudo sed -i "s/run_as shiny/run_as $USER/" /etc/shiny-server/shiny/server.conf
sudo sed -i "s/3838/ 3838 0.0.0.0/" /etc/shiny-server/shiny/server.conf
sudo sed -i "s/site_dir \/srv\/shiny-server/site_dir \/home\/$USER\/shiny/" /etc/shiny-server/shiny/server.conf
mkdir $HOME/shiny

# Copy sample apps to users new Shiny dir
cp -r /opt/shiny-server/samples/sample-apps/hello/ ~/shiny

# Tell user to reboot
echo Please reboot before trying your new RStudio Server/Shiny Server install.
