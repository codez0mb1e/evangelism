### Install MS R Open  ----
wget https://mran.blob.core.windows.net/install/mro/3.4.2/microsoft-r-open-3.4.2.tar.gz
 
tar -xf microsoft-r-open-3.4.2.tar.gz
cd microsoft-r-open/
sudo ./install.sh



### Install MS R Client and/or MS ML Server  ----
wget http://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb 
dpkg -i packages-microsoft-prod.deb
ls -la /etc/apt/sources.list.d

sudo apt-get update

# for R Client
sudo apt-get install microsoft-r-client-packages-3.4.1
ls /opt/microsoft/rclient/3.4.1/

# for ML Server
sudo apt-get install microsoft-mlserver-all-9.2.1
/opt/microsoft/mlserver/9.2.1/bin/R/activate.sh



### Advanced tools ----
# install RStudio Server
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
sudo gdebi rstudio-server-1.1.383-amd64.deb

# open SSH tunnel
ssh -N -L 8787:localhost:8787 dp@rclient.westus.cloudapp.azure.com
