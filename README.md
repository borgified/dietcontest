##Screenshots
### Main Page
<img src="https://github.com/downloads/borgified/dietcontest/Screenshot-3.png">

### Login Page
<img src="https://github.com/downloads/borgified/dietcontest/Screenshot-4.png">

### Leaderboard
<img src="https://github.com/downloads/borgified/dietcontest/Screenshot-2.png">


### Install (Perl modules & Ubuntu packages dependencies)

1. Ubuntu packages
`sudo apt-get install apache2 mysql-server phpmyadmin git-core`

2. and these perl modules:
`sudo apt-get install libmime-base64-urlsafe-perl libchart-strip-perl`

3. then make a user named "fwiffo" (or alternatively you can modify the apache config files to point to the right directories)

<pre>
sudo adduser fwiffo
su fwiffo
cd ~fwiffo
mkdir scripts
cd scripts
</pre>

4. grab the app
`git clone https://github.com/borgified/dietcontest.git`

5. make links so apache can read the config file that is provided, and get rid of the existing 0default link, restart apache2
<pre>
cd /etc/apache2/sites-enabled
sudo ln -s /home/fwiffo/scripts/dietcontest/utils/apache2/dietcontest
sudo rm 0default
sudo /etc/init.d/apache2 restart
</pre> 

6. create your tables with the predefined structure, assumes no root password for mysql root user, if you do have a password just modify this line in the scripts: my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '<password here>')
<pre>
mysql -uroot -p
source /home/fwiffo/scripts/dietcontest/utils/mysql/dietcontest.mysql
</pre>

7. that's it, just browse over to http://localhost/ for the main page. to zero out all the values in the database, just go to http://localhost/phpmyadmin and click on the "Empty" tab for each table. be sure to repopulate the avatars table using the helper script afterwards:
<pre>
cd /home/fwiffo/scripts/dietcontest/utils
./installavatars.pl
</pre>
