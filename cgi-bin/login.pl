#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;
use Crypt::Lite;

#check in weight
#graphs to track progress

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

my $sth=$dbh->prepare("select email,password,avatar from users");
$sth->execute();
my(%users,%avatars);

while(my($email,$password,$avatar)=$sth->fetchrow_array){
	$users{$email}=$password;
	$avatars{$email}=$avatar;
}

print header;

print start_form;


print "email: ",textfield(
	-name		=> 'email',
	-value		=> '',
	-size		=> 20,
	-maxlength	=> 40,
),br;

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

my $email=param('email');
my $password=param('password');

print hr;

if($password eq ''){
	print "enter your password";exit;
}elsif($email eq ''){
	print "enter your email";exit;
}elsif($password eq $users{$email}){
	print "<img src='/avatars/$avatars{$email}.png'>",br;
	print "weight check-in: ",textfield(
		-name 	=> 'weight',
		-value 	=> '',
		-size	=> 3,
		-maxlength => 5,
	)," lbs";
}else{
	print "wrong password, try again.";exit;
}
		
print end_form;
my $weight=param('weight');
if($weight=~/\d+/){
	$sth=$dbh->prepare("insert into checkin (weight,email) values (\'$weight\',\'$email\')");
	$sth->execute();
}

print "<table border='1'><tr><th>timestamp</th><th>weight</th></tr>";
$sth=$dbh->prepare("select timestamp,weight from checkin where email=\'$email\' order by timestamp desc limit 5");
$sth->execute();
while(my($timestamp,$weight)=$sth->fetchrow_array){
	print "<tr><td>$timestamp</td><td>$weight</td></tr>";
}
print "</table>";
print hr;
#print '<img src="/cgi-bin/graph.pl?email='.$email.'&password='.$password.'">';
my $crypt=new Crypt::Lite;
$encrypted=$crypt->encrypt($email,'secret');
print '<img src="/cgi-bin/graph.pl?a='.$encrypted.'">';
