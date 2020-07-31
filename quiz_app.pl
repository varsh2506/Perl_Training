use DBI;
use strict;
use warnings;

#Opening and setting up connection with database
my $driver   = "SQLite"; 
my $database = "test.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
   or die $DBI::errstr;

print "Opened database successfully\n";


#Creates Account and Topic list tables if they don't exist already
sub create_table {
	my $sql = qq(CREATE TABLE IF NOT EXISTS ACCOUNT
		(USER_NAME TEXT PRIMARY KEY NOT NULL,
		USER_TYPE TEXT NOT NULL););

	my $rv = $dbh->do($sql);
	
	if ($rv<0) {
		print $DBI::errstr;
	} else {
		print "Account Table created successfully\n";
		my $sql = qq(CREATE TABLE IF NOT EXISTS TOPIC_LIST (TOPIC_ID INTEGER PRIMARY KEY AUTOINCREMENT, TOPIC_NAME TEXT NOT NULL););
		my $stmt = $dbh->prepare($sql);
		$rv = $stmt->execute();
		
	}
}

#Add an entry in case of new account or recognize an existing account
sub create_account {
	print "Enter user name: ";
	chomp (my $name = <STDIN>);
	#$name = "'".$name."'";
	my $sql = "SELECT USER_TYPE FROM ACCOUNT WHERE USER_NAME = ?";
	#my $sql = "SELECT * FROM ACCOUNT";
	my $stmt = $dbh->prepare($sql);
	$stmt->execute($name);
	my @row = $stmt->fetchrow_array();
	
	if (!(scalar(@row))) {
		print "Choose login type (admin or user): ";
		my $login_type = <STDIN>;
		chomp $login_type;
		$sql = "INSERT INTO ACCOUNT(USER_NAME, USER_TYPE) VALUES (?, ?)";
		$stmt = $dbh->prepare($sql);
		if ($stmt->execute($name, $login_type)) {
			print "Account created successfully!\n\n";
		}
		return $login_type;
	} else {	
		while(@row) {
			my $user_type  = $row[0];
			print "You are an already registered $user_type \n";
			return $user_type;
			}	
		}	
		
		
	}
		
#Create a new topic table (only registered admin can do this)
sub create_topic_table {
	my $topic = $_[0];
	#$topic = "'".$topic."'";	
	my $sql = "CREATE TABLE IF NOT EXISTS $topic (
    questionID INTEGER PRIMARY KEY AUTOINCREMENT,
    question varchar(255),
    option1 varchar(255),
    option2 varchar(255),
    option3 varchar(255),
	option4 varchar(255),
	correctop INTEGER
);";
	my $stmt = $dbh->prepare($sql);
	if ($stmt->execute()) {
		print "Topic table created!\n\n";
		my $sql = "INSERT INTO TOPIC_LIST (TOPIC_NAME) VALUES (?)";
		my $stmt = $dbh->prepare($sql);
		$stmt->execute($topic);
	}
	
	
}

#Adds as many questions as the admin wants for a particular topic 
sub add_questions {
	my $topic = $_[0];
	my($question, $op1, $op2, $op3, $op4, $correct);
	
	my $want_to_add = 'y';
	while ($want_to_add eq 'y') {
		print "Enter question: ";
		chomp($question = <STDIN>);
	
		print "Enter option 1: ";
		chomp ($op1 = <STDIN>);

		print "Enter option 2: ";
		chomp ($op2 = <STDIN>);
	
		print "Enter option 3: ";
		chomp ($op3 = <STDIN>);

		print "Enter option 4: ";
		chomp ($op4 = <STDIN>);

		print "Enter correct option number (1, 2, 3, 4): ";
		chomp ($correct = <STDIN>);
	
		my $sql = "INSERT INTO $topic(question, option1, option2, option3, option4, correctop) VALUES (?, ?, ?, ?, ?, ?)";
		my $stmt = $dbh->prepare($sql);

		if ($stmt->execute($question, $op1, $op2, $op3, $op4, $correct)) {
			print "Question inserted!\n";
		}	
		print "Do you want to continue entering questions? (y/n) ";
		chomp ($want_to_add = <STDIN>);
	}
}

#Enables the user take a test depending on the topic chosen and displays the score
sub take_quiz {
	my $no_of_questions = $_[0];
	my $topic = $_[1];
	my $score = 0;
	my $sql = "SELECT * FROM $topic ORDER BY random() LIMIT $no_of_questions";
	my $stmt = $dbh->prepare($sql);
	my $rv =  $stmt->execute() or die $DBI::errstr;
	
	if ($rv<0) {
		print $DBI::errstr;
	}
	my $ct = 1;
	while(my @row = $stmt->fetchrow_array()) {
		print "Q no. ".$ct. " ";
		print $row[1] ."\n";
		print "option1 = ". $row[2] ."\n";
		print "option2 =  ". $row[3] ."\n";
		print "option3 = ".$row[4] ."\n";
		print "option4 = ".$row[5] ."\n";
		print "Enter your answer (1, 2, 3, 4): ";
		chomp(my $entered_op = <STDIN>);
		if ($entered_op==$row[6]) {
			$score+=1
	    }
		else {
			print "Sorry, that's the wrong answer. The correct answer is option".$row[6]."\n";
		}
		print "\n";
		$ct+=1;
	}
	
	print "Your score for the quiz is: $score\n";
	
	
	
}

#Displays the list of all quiz topics available
sub display_topics {
	my $sql = "SELECT * FROM TOPIC_LIST";
	my $stmt = $dbh->prepare($sql);
	$stmt->execute();
	my @row = $stmt->fetchrow_array();
	if (!scalar(@row)) {
		print "List of quiz topics: \n";
	}
	$stmt->execute();
	while (@row = $stmt->fetchrow_array()) {
		print $row[0]. " ";
		print $row[1]. "\n";
	}
}
		
#Main code starts here
print "\t\tWELCOME TO THE QUIZ APPLICATION\n";
create_table();
my $user_type = create_account();
if ($user_type eq "admin") {	
	my $continue_change = 'y';
	while ($continue_change eq 'y') {
		display_topics();
		print "Enter 1 to add a new topic and 2 to make changes to an existing topic: ";
		chomp (my $new_old = <STDIN>);
		if ($new_old == 2) {	
		
			print "Choose topic you wish to make changes to (enter id): \n";
			chomp (my $chosen_id = <STDIN>);		
			my $sql = "SELECT TOPIC_NAME FROM TOPIC_LIST WHERE TOPIC_ID = $chosen_id";
			my $chosen_topic = $dbh->selectrow_array($sql);
			print "List of questions already available for this quiz topic: \n";
			$sql = "SELECT questionID, question FROM $chosen_topic";
			my $stmt = $dbh->prepare($sql);
			$stmt->execute();
			while (my @row = $stmt->fetchrow_array()) {
				print $row[0]." ";
				print $row[1]."\n";
			}
			print "Enter 1 to add a question and 2 to delete a question: ";
			chomp (my $add_delete = <STDIN>);
			if ($add_delete == 1) {
				add_questions($chosen_topic);
			} else {
				my $want_to_delete = 'y';
				while ($want_to_delete eq 'y') {
					print "Enter question ID for the question you want to delete: ";
					chomp (my $delete_id = <STDIN>);
					$sql = "DELETE FROM $chosen_topic WHERE questionID == $delete_id";
					$stmt = $dbh->prepare($sql);
					$stmt->execute();
				
					print "Do you want to delete any more questions? (y/n) ";
					chomp ($want_to_delete = <STDIN>);
				}
			}
		}
		
	 else {
		my $topic;
		print "Enter topic: ";
		chomp($topic = <STDIN>);
		create_topic_table($topic);
		add_questions($topic);
			
	}
	print "Do you wish to make changes to any more topic? (y/n) ";
	chomp ($continue_change = <STDIN>);
	
}} else {
	display_topics();
	print "Which topic do you want to take a quiz on? (Enter id): ";
	chomp (my $test_topic = <STDIN>);
	my $sql = "SELECT TOPIC_NAME FROM TOPIC_LIST WHERE TOPIC_ID = $test_topic";
	my $stmt = $dbh->prepare($sql);
	$stmt->execute();
	while (my @row = $stmt->fetchrow_array()) {
		my $test_topic_name = $row[0];
		take_quiz(10, $test_topic_name);
	}
}
	
	
		
	
