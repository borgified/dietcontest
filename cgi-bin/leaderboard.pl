#!/usr/bin/perl -w

use Date::Calc qw/:all/;
use DBI;
use CGI qw/:standard/;
use Date::Manip;

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

my $sth=$dbh->prepare("select avatar,email,nickname from users");
$sth->execute;
my(%db,%nickname);
while(my($avatar,$email,$nickname)=$sth->fetchrow_array){
	$db{$avatar}=$email;
	$nickname{$avatar}=$nickname;
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
	and the last check-in for (8-23-2011 to 9-5-2011) is 95, 
then
	the formula is: (95-100)/100 = -5 percent

HTML

print "<table border=1>";

my @avatars=keys(%db);

my @sorted=&orderedAvatars(0,\@avatars);
&orderedAvatars(1,\@sorted);

sub orderedAvatars{
#gotta run through all the same logic once to get the percentage result for each user,
#then we can sort the avatars from biggest weight loss to least.
#we're gonna sort by the time period that we are currently in. ie. there may be diff leaders
#in each time period, but we're only gonna sort by the current time period.

	my($printflag)=shift(@_);
	my($arrayOfAvatars)=shift(@_);
	my %output;

	foreach my $avatar (@$arrayOfAvatars){


		$printflag && print "<tr><td><img src='/avatars/$avatar.png'>$nickname{$avatar}</td>";
		my($pmonth,$pday,$pyear,$pweight)=(0) x 4;


		for(my $i=0;$i<$tourney_days;$i++){
			if($i%14 == 0){

				my($year,$month,$day)=Add_Delta_Days($starty,$startm,$startd,$i);
				$month=sprintf("%02d",$month);
				$day=sprintf("%02d",$day);

				$sth=$dbh->prepare("select weight from checkin where email=\'$db{$avatar}\' and timestamp < \'$year-$month-$day 23:59:59\' and timestamp > \'$pyear-$pmonth-$pday 23:59:59\' order by timestamp desc limit 1");
				$sth->execute();

				my($weight)= $sth->fetchrow_array;
			
				if(!defined($weight) or !defined($pweight) or $pweight == 0){
					$printflag && print "<td>$pmonth-$pday-$pyear ... $month-$day-$year</td>";

#save placeholders for those who didnt check in (no percentage data)
					my $lower;
					if($pyear==0){
						$lower=0;
					}else{
						$lower = Date_to_Days($pyear,$pmonth,$pday);
					}
					my $upper = Date_to_Days($year,$month,$day);
					my ($tyear,$tmonth,$tday)=Today();
					my $date = Date_to_Days($tyear,$tmonth,$tday);
					if(($date >= $lower) && ($date <= $upper)){
						$output{$avatar}=1000; #just assign some big number so they end up at the bottom of the list (assuming no one is going to increase 1000% of their weight...)
					}


				}else{
					my $percentage=sprintf("%.2f",(($weight-$pweight)/$pweight)*100);
					$printflag && print "<td bgcolor='lightblue'>$percentage</td>";

#save percentage data only for the time period that we are currently in now
					my $lower = Date_to_Days($pyear,$pmonth,$pday);
					my $upper = Date_to_Days($year,$month,$day);
					my ($tyear,$tmonth,$tday)=Today();
					my $date = Date_to_Days($tyear,$tmonth,$tday);
					if(($date >= $lower) && ($date <= $upper)){
						$output{$avatar}=$percentage;
					}
				}
				$pmonth=$month;
				$pday=$day;
				$pyear=$year;
				$pweight=$weight;

			}
		}
		$printflag && print "</tr>";
	}
my @sorted = sort { $output{$a} <=> $output{$b} } keys %output;
return @sorted;

} #end sub orderedAvatars

print "</table>";
