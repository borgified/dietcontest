#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;
use GD::Graph::lines;
use Crypt::Lite;

#check in weight
#graphs to track progress

my $crypt=Crypt::Lite->new;
my $encrypted=param('a');
my $email=$crypt->decrypt($encrypted,'secret');

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '')
    || die "Could not connect to database: $DBI::errstr";

my $sth=$dbh->prepare("select timestamp,weight from checkin where email=\'$email\' order by timestamp");
$sth->execute();
my @timestamp;
my @weight;
while(my($timestamp,$weight)=$sth->fetchrow_array){
    push(@timestamp,$timestamp);
    push(@weight,$weight);
}


my @data = (\@timestamp,\@weight);
my $graph = GD::Graph::lines->new(600,300);
$graph->set(
	x_label		=> '',
	y_label		=> 'weight',
	line_type	=> 1,
	line_width	=> 2,
) or warn $graph->error;

my $img = $graph->plot(\@data) or die $graph->error;

binmode STDOUT;

print header("image/png");
print $img->png;

