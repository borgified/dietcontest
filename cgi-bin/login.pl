#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;

#check in weight
#graphs to track progress

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

my $sth=$dbh->prepare("select avatar,password from users");
$sth->execute();
my %users;
while(my($avatar,$password)=$sth->fetchrow_array){
	$users{$avatar}=$password;
}

print header;

print start_form;

print "<table><tr>";
foreach my $avatar (keys %users){
	print "<td><label><input type='radio' name='avatar' value=$avatar><img src='/avatars/$avatar.png'></label></td>";
}
print "</tr></table>";

print "password: ",password_field(
	-name		=> 'password',
	-value		=> '',
	-size		=> 20,
	-maxlength	=> 40,
),br;
print submit(
	-name		=> 'submit_form',
	-value		=> 'Submit',
);

my $avatar=param('avatar');
my $password=param('password');

print hr;

if($password eq ''){
	print "enter your password";
}elsif($avatar eq ''){
	print "pick your avatar";
}elsif($password eq $users{$avatar}){
	print "weight check-in: ",textfield(
		-name 	=> 'weight',
		-value 	=> '',
		-size	=> 3,
		-maxlength => 5,
	);
}else{
	print "wrong password, try again.";
}
		

print end_form;
#my $sth_users=$dbh->prepare("select email,
