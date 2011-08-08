#!/usr/bin/perl -w

use Date::Calc qw/:all/;
use DBI;
use CGI qw/:standard/;

#enter start & end dates for contest YYYYMMDD
my $startdate="20110808";
my $enddate="20111216";

$startdate=~/(\d{4})(\d{2})(\d{2})/;
my $starty=$1;
my $startm=$2;
my $startd=$3;
$enddate=~/(\d{4})(\d{2})(\d{2})/;
my $endy=$1;
my $endm=$2;
my $endd=$3;


my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";


my $tourney_days=Delta_Days($starty,$startm,$startd,$endy,$endm,$endd);

my $sth=$dbh->prepare("select avatar,email from users");
$sth->execute;
my @avatars;
my %db;
while(my($avatar,$email)=$sth->fetchrow_array){
	$db{$avatar}=$email;
}

$sth=$dbh->prepare("select checkin.timestamp,users.avatar from checkin on checkin.email = users.email");



print header,start_html;
print <<HTML;
<a href="/"><img src="/img/eluder.png"></a>
<li>all values in percentages, if no value can be calculated, the corresponding check-in period is shown
<li>for each weighing period, the last check-in weight of each period is considered for calculation purposes
<pre>
for example: 

if the last check-in for (8-09-2011 to 8-22-2011) is 100
	and the last check-in for (8-23-2011 to 9-5-2011) is 105, 
then
	the formula is: (100-105)/100 = -5 percent

HTML

print "<table border=1>";

foreach my $avatar (keys(%db)){


	print "<tr><td><img src='/avatars/$avatar.png'></td>";
	my($pmonth,$pdayplusone,$pyear,$pweight)=(0,0,0,0);


	for(my $i=0;$i<$tourney_days;$i++){
		if($i%14 == 0){

			my($year,$month,$day)=Add_Delta_Days($starty,$startm,$startd,$i);
			$month=sprintf("%02d",$month);
			$day=sprintf("%02d",$day);
			$dayplusone=sprintf("%02d",$day+1);

			$sth=$dbh->prepare("select weight,timestamp from checkin where email=\'$db{$avatar}\' and timestamp < \'$year-$month-$dayplusone 00:00:00\' and timestamp > \'$pyear-$pmonth-$pdayplusone 00:00:00\' order by timestamp desc limit 1");
			$sth->execute();

			my($weight)= $sth->fetchrow_array;
			
			if($pweight==0 or $weight==0){
				print "<td>$pmonth-$pdayplusone-$pyear ... $month-$day-$year</td>";
			}else{
				my $percentage=sprintf("%.2f",(($weight-$pweight)/$pweight)*100);
				#print "<td>$pmonth-$pdayplusone-$pyear ... $month-$day-$year $weight $percentage</td>";
				print "<td bgcolor='lightblue'>$percentage</td>";
			}
			$pmonth=$month;
			$pdayplusone=$dayplusone;
			$pyear=$year;
			$pweight=$weight;

		}
	}
	print "</tr>";
}
print "</table>";
