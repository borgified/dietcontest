#!/usr/bin/perl -w

use Date::Calc qw/:all/;
use DBI;
use CGI qw/:standard/;

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

my $tourney_days=Delta_Days(2011,8,8,2011,12,15);

my $sth=$dbh->prepare("select avatar from users");
$sth->execute;
my @avatars;
while(my($avatar)=$sth->fetchrow_array){
	push(@avatars,$avatar);
}

$sth=$dbh->prepare("select checkin.timestamp,users.avatar from checkin on checkin.email = users.email");



print header,start_html;
print "<a href='/'><img src='/img/eluder.png'></a>";
print "this is not implemented yet";
print "<table border=1>";

foreach my $avatar (@avatars){
	print "<tr>";
	for(my $i=0;$i<$tourney_days;$i++){
		if($i%14 == 0){

			my($year,$month,$day)=Add_Delta_Days(2011,8,8,$i);
			print "<td>$month-$day-$year</td>";
		}
	}
	print "</tr>";
}
print "</table>";
