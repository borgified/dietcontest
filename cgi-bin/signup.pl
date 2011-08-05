#!/usr/bin/perl -w

use CGI qw/:standard/;
use DBI;

#table avatars: filename,url,used
#table users: uid,avatar,timestamp,weight,email

my $dbh = DBI->connect('DBI:mysql:dietcontest', 'root', '') 
	|| die "Could not connect to database: $DBI::errstr";

print header,start_html;
print h3("sign up form for diet contest 2011");
print start_form;
print "input your email: ",textfield(
	-name		=> 'email',
	-value		=> '',
	-size		=> 20,
	-maxlength	=> 40,
)," (eg. fwiffo.ofspathiwa\@ingres.com)",br;
print "pick a password: ",textfield(
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

#get an array of unclaimed avatars
my @avatars;
my $sth_avatars=$dbh->prepare("select filename from avatars where used = 0");
$sth_avatars->execute();
while(my(@avatar)=$sth_avatars->fetchrow_array){
	push(@avatars,shift(@avatar)); 
}
$sth_avatars=$dbh->prepare("update avatars set used = 1 where filename = ?");

my $size_of_avatars=@avatars;
#pick a random avatar
my $avatar=$avatars[int(rand($size_of_avatars))];

my %emails;
my $sth_users=$dbh->prepare("select email from users");
$sth_users->execute();
while(my(@email)=$sth_users->fetchrow_array){
	$emails{shift(@email)}=1; 
}

my $email=param('email');
my $password=param('password');

if($password eq ''){
	print hr,"your password cannot be blank!";
	exit;
}

if($email ne ''){
	print hr;
	if($size_of_avatars == 0){
		print "sorry i ran out of avatars to hand out, cannot continue.";
		print end_html;
		exit;
	}
	if(exists($emails{$email})){
		print "this email is already in the database!";
	}elsif($email !~ /^(\w|\-|\_|\.)+\@ingres.com/){
		print "enter a valid \@ingres.com email";
	}else{
		$sth_users=$dbh->prepare("insert into users (avatar,email,password) values (\'$avatar\',\'$email\',\'$password\')");
		$sth_users->execute;
		$sth_avatars=$dbh->prepare("update avatars set used = 1 where filename = \'$avatar\'");
		$sth_avatars->execute;
		print "thanks for signing up, you can now <a href='/cgi-bin/login.pl'>log in</a><br>";
		print "you have been assigned this avatar: <img src='/avatars/$avatar.png'>";
	}
}
