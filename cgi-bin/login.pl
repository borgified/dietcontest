#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;

#check in weight
#graphs to track progress

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

print header;

print start_form;
print "email: ",textfield(
	-name		=> 'email',
	-value		=> '',
	-size		=> 20,
	-maxlength	=> 40,
)," (eg. fwiffo.ofspathiwa\@ingres.com)",br;
print "password: ",textfield(
	-name		=> 'password',
	-value		=> '',
	-size		=> 20,
	-maxlength	=> 40,
),br;
print submit(
	-name		=> 'submit_form',
	-value		=> 'Submit',
);
print end_form;


#my $sth_users=$dbh->prepare("select email,
