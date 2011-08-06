#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;
use MIME::Base64::URLSafe;

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

print header,start_html(-style => { -src => '/style.css'});
print "<a href='/'><img src='/img/eluder.png'></a>";
print "<div id='stylized' class='myform'>";
print start_form;

print "<label>";
print "email:</label>",textfield(
-id => 'email',
-name => 'email',
-value => '',
-size => 20,
-maxlength => 40,
);

print "<label>";
print "password:</label>",password_field(
-id => 'password',
-name => 'password',
-value => '',
-size => 20,
-maxlength => 40,
);
print submit(
-name => 'submit_form',
-value => 'Submit',
);
print "<div class='spacer'></div>";

my $email=param('email');
my $password=param('password');

print hr;

if($password eq ''){
	print "enter your password";exit;
}elsif($email eq ''){
	print "enter your email";exit;
}elsif($password eq $users{$email}){
	print "<img src='/avatars/$avatars{$email}.png'>",br;
	print "<label>weight check-in:</label>
	<span class='small'>hit Submit again</span>",textfield(
		-id		=> 'email',
		-name 	=> 'weight',
		-value 	=> '',
		-size	=> 8,
		-maxlength => 8,
	);
}else{
	print "wrong password, try again.";exit;
}

print "<div class='spacer'></div>";

print end_form;
print "</div>";
		
my $weight=param('weight');
if($weight=~/\d+/){
	$sth=$dbh->prepare("insert into checkin (weight,email) values (\'$weight\',\'$email\')");
	$sth->execute();
}

print h3("last 5 check-ins");
print "<table border='1'><tr><th>timestamp</th><th>weight</th></tr>";
$sth=$dbh->prepare("select timestamp,weight from checkin where email=\'$email\' order by timestamp desc limit 5");
$sth->execute();
while(my($timestamp,$weight)=$sth->fetchrow_array){
	print "<tr><td>$timestamp</td><td>$weight</td></tr>";
}
print "</table>";
print hr;
#print '<img src="/cgi-bin/graph.pl?email='.$email.'&password='.$password.'">';
$encrypted=MIME::Base64::URLSafe::encode($email);
print '<img src="/cgi-bin/graph.pl?a='.$encrypted.'">';


__END__

print <<HTML;

<div id="stylized" class="myform">
<form method="post" action="/cgi-bin/login.pl" enctype="multipart/form-data">
<h1>Weight Check-ins</h1>
<label>Email
<span class="small">eg. jack.black\@ingres.com</span>
</label>
<input type="text" name="email" id="email" size="20" maxlength="40">

<label>Password
<span class="small">anything is fine</span>
</label>
<input type="password" name="password" id="password" size="20" maxlength="40">

<button type="submit">Log In</button>
<div class="spacer"></div>
</form>
</div>
HTML
