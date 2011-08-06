#!/usr/bin/perl -w

use Date::Calc qw/:all/;
use DBI;

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

my $dd=Delta_Days(2011,8,8,2011,12,15);


