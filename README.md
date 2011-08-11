##Screenshots
### Main Page
<img src="https://github.com/downloads/borgified/dietcontest/Screenshot-3.png">

### Login Page
<img src="https://github.com/downloads/borgified/dietcontest/Screenshot-4.png">

### Leaderboard
<img src="https://github.com/downloads/borgified/dietcontest/Screenshot-2.png">


### Install (Perl modules & Ubuntu packages dependencies)

1.
`sudo apt-get install apache2 mysql-server phpmyadmin git-core`

and these perl modules:

2.
`sudo apt-get install libmime-base64-urlsafe-perl libchart-strip-perl libdate-manip-perl libdate-calc-perl`

then make a user named "fwiffo" (or alternatively you can modify the apache config files to point to the right directories)

3.
	sudo adduser fwiffo
	su fwiffo
	cd ~fwiffo
	mkdir scripts
	cd scripts

4. grab the app
`git clone https://github.com/borgified/dietcontest.git`

5. make links so apache can read the config file that is provided, and get rid of the existing 0default link, restart apache2
	cd /etc/apache2/sites-enabled
	sudo ln -s /home/fwiffo/scripts/dietcontest/utils/apache2/dietcontest
	sudo rm 0default
	sudo /etc/init.d/apache2 restart

6. create your tables with the predefined structure, assumes no root password for mysql root user, if you do have a password just modify this line in the scripts: my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '<password here>')

	mysql -uroot -p
	source /home/fwiffo/scripts/dietcontest/utils/mysql/dietcontest.mysql

7. that's it, just browse over to http://localhost/ for the main page. to zero out all the values in the database, just go to http://localhost/phpmyadmin and click on the "Empty" tab for each table. be sure to repopulate the avatars table using the helper script afterwards:

	cd /home/fwiffo/scripts/dietcontest/utils
	./installavatars.pl

