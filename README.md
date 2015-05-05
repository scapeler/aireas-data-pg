# aireas-data-pg
AiREAS data retrieval and publish service based on PostgreSQL/PostGIS 


# Install server

Install Ubuntu 14.04 LTS

# Install database

Install PostgreSQL/PostGIS database
Install Git: sudo apt-get install git
Install Nodejs


# Install package

sudo mkdir /opt/SCAPE604
cd /opt/SCAPE604
sudo mkdir log
sudo mkdir config
sudo mkdir -p aireas/aireas
 
clone Github repository: 
sudo git clone https://github.com/scapeler/aireas-data-pg.git

cd /opt/SCAPE604/aireas-data-pg
cp config-sample/apri-system.json /opt/SCAPE604/config/.
change database settings ip/account/password in apri-system.json
