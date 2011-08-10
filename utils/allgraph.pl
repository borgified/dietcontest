#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;
use MIME::Base64::URLSafe;
use Chart::Strip;
use Date::Manip;

#my $encrypted=param('a');
#my $email=MIME::Base64::URLSafe::decode($encrypted);

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '')
    || die "Could not connect to database: $DBI::errstr";




my $sth_email=$dbh->prepare("select distinct email from checkin");
$sth_email->execute();
my @emails;
while(my($email)=$sth_email->fetchrow_array){
	push(@emails,$email);
}

my $graph = Chart::Strip->new(	title		=> '',
								x_label		=> '',
								y_label		=> '',
								transparent => 0,
);

my @colors=("000000","0000FF","00FF00","00FFFF","FF0000","FF6600","FF00FF","006600","660000");


foreach my $email (@emails){

	my $sth=$dbh->prepare("select timestamp,weight from checkin where email=\'$email\' order by timestamp");
	$sth->execute();
	my @timestamp;
	my @weight;
	my $data;

	while(my($timestamp,$weight)=$sth->fetchrow_array){
		my $unixdate=UnixDate(ParseDate($timestamp),"%s");
		push @$data, {time => $unixdate, value => $weight};
	}

	$colorsize=@colors;
	$color=$colors[int(rand($colorsize))];
	#$graph->add_data( $data, { color=>$color, label => $email, style => 'line' });
	$graph->add_data( $data, { color=>$color, style => 'line' });
}


binmode STDOUT;
print header("image/png");
print $graph->png;

