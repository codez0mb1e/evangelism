## install last updates
sudo apt-get update        # Fetches the list of available updates
sudo apt-get upgrade       # Strictly upgrades the current packages
sudo apt-get dist-upgrade  # Installs updates (new ones)



## Install MS R Open  ----
wget https://mran.blob.core.windows.net/install/mro/3.4.2/microsoft-r-open-3.4.2.tar.gz

tar -xf microsoft-r-open-3.4.2.tar.gz
cd microsoft-r-open/
sudo ./install.sh



### Install MS R Client and/or MS ML Server  ----
wget http://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb 
sudo dpkg -i packages-microsoft-prod.deb
ls -la /etc/apt/sources.list.d

## install MS R Client
sudo apt-get install microsoft-r-client-packages-3.4.1
ls /opt/microsoft/rclient/3.4.1/

## or install MS ML Server
sudo apt-get install microsoft-mlserver-all-9.2.1
/opt/microsoft/mlserver/9.2.1/bin/R/activate.sh



### Advanced tools ----
## Install RStudio Server
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
sudo gdebi rstudio-server-1.1.383-amd64.deb

# implicitly define R Version for RStudio (optional)
export RSTUDIO_WHICH_R=/usr/bin/Revo64
# or 
sudo nano /etc/rstudio/rserver.conf # add key to config: rsession-which-r=/usr/bin/Revo64

# open SSH tunnel (usually already open)
ssh -N -L 8787:localhost:8787 <user>@<host>.cloudapp.azure.com #! specify user and host


## Install R packages builders dependencies
sudo apt-get install build-essential
sudo apt-get install libcurl4-openssl-dev libssl-dev
sudo apt-get install gfortran


## Monitoring/admin utils
sudo apt-get install htop


## .NET Core (optional)
# see: https://www.microsoft.com/net/learn/get-started/linuxubuntu


## Git + VSTS integration 
sudo apt-get install git

ssh-keygen -C "<azure_user_name>" # create ssh-key
cat /home/<user>/.ssh/id_rsa.pub # view public created key
# register public key to VSTS. See: https://www.visualstudio.com/en-us/docs/git/use-ssh-keys-to-authenticate
ssh -T <VSTS_account_name>@<VSTS_account_name>.visualstudio.com # test connection

mkdir /home/<user>/apps
cd  /home/<user>/apps
git clone ssh://<VSTS_account_name>@vs-ssh.visualstudio.com:22/DefaultCollection/_ssh/<project_name> # clone repository


