#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;
use MIME::Base64::URLSafe;
use Chart::Strip;
use Date::Manip;

my $encrypted=param('a');
my $email=MIME::Base64::URLSafe::decode($encrypted);

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '')
    || die "Could not connect to database: $DBI::errstr";

my $sth=$dbh->prepare("select timestamp,weight from checkin where email=\'$email\' order by timestamp");
$sth->execute();
my @timestamp;
my @weight;
while(my($timestamp,$weight)=$sth->fetchrow_array){
	my $unixdate=UnixDate(ParseDate($timestamp),"%s");
	#print "$weight";
	push @$data, {time => $unixdate, value => $weight};
}

my $graph = Chart::Strip->new(	title		=> '',
								x_label		=> '',
								y_label		=> '',
								transparent => 0,
);

$graph->add_data( $data, { label => '', style => 'line' });


binmode STDOUT;
print header("image/png");
print $graph->png;

