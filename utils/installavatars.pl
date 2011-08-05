#!/usr/bin/perl -w

#get more avatars here: http://wiki.farmvillefeed.com/index.php/Animals
#adds new avatars (.pngs) into avatars table in database
#1. copy new .pngs into /home/jctong/dietcontest/html/avatars
#2. run this script

use DBI;

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

my $sth=$dbh->prepare("insert into avatars (filename,url,used) values (?,?,0)");

@files=<../html/avatars/*.png>;

foreach my $file (@files){
	$file=~/.*\/(.*).png/;
	$filename=$1;
	$file=~/(avatars\/.*png)/;
	$url=$1;
	$sth->execute($filename,$url);
}
