# aireas-data-pg
AiREAS data retrieval and publish service based on PostgreSQL/PostGIS 


THIS IS WORK IN PROGRESS !!

# Install server

- Install Ubuntu 14.04 LTS

# Install software

- Install Git: sudo apt-get install git
- Install Nodejs

# Install database

- Install PostgreSQL/PostGIS database
- execute sql-scripts in package/pgplsql
- Download and insert CBS-data into database (CBS 2012)

plus:
- add grid definition
- insert cells of grid (depends on airea envelope. Scripts depend on CBS-data, only for the Netherlands)

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
	
Automatic start data retrieval
	add script to root crontab:
	sudo su -
	crontab -e
	*/10 * * * * /opt/SCAPE604/config/aireasdata-get-cron.sh

# Copyright and disclaimer

Copyright (C) 2015, Scapeler

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
