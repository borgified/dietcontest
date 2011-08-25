#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard/;

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '')
        || die "Could not connect to database: $DBI::errstr";

#gather everyones starting weight into %start_weight
my $sth=$dbh->prepare("select timestamp,email,weight from checkin order by timestamp");
$sth->execute;
while(my($timestamp,$email,$weight)=$sth->fetchrow_array){
	if(!exists($start_weight{$email})){
		$start_weight{$email}=$weight;
	}
}

#gather everyones most current weight into %end_weight
$sth=$dbh->prepare("select timestamp,email,weight from checkin order by timestamp desc");
$sth->execute;
while(my($timestamp,$email,$weight)=$sth->fetchrow_array){
	if(!exists($end_weight{$email})){
		$end_weight{$email}=$weight;
	}
}

#calculate the percentage weight loss and store it into %result
foreach my $email (keys %start_weight){
	$percentage=sprintf("%.2f",(($end_weight{$email}-$start_weight{$email})/$start_weight{$email})*100);
	$result{$email}=$percentage;
}

#sort %result by amount lost
my @sorted = sort { $result{$a} <=> $result{$b} } keys %result;

#this loop to display %result to make sure it was sorted correctly
#foreach my $email (@sorted){
#	print "$email $result{$email}\n";
#}

#now we have to figure out which avatar each email belongs to. might as well get their avatar's nickname too.
$sth=$dbh->prepare("select avatar,email,nickname from users");
$sth->execute;
my(%db,%nickname);
while(my($avatar,$email,$nickname)=$sth->fetchrow_array){
        $email2avatar{$email}=$avatar;
        $nickname{$email}=$nickname;
}

#we have all the data we need, time to print html
print header,start_html;
print <<HTML;
<a href="/"><img src="/img/eluder.png"></a>
<table border=1>
HTML

foreach my $email (@sorted){ 
	print "<tr><td><img src='/avatars/$email2avatar{$email}.png'>$nickname{$email}</td>";
	print "<td>$result{$email}%</td></tr>\n";
}

print "</table>",end_html;
